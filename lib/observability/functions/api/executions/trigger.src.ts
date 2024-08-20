import { PublishCommand, SNSClient } from '@aws-sdk/client-sns';
import { randomUUID } from 'crypto';
import { getCurrentUser, HandleDelivery } from '../../../../common/utils/api';
import { DalClient } from '../../dal/client';
import { ApiGatewayManagementApiClient, PostToConnectionCommand } from '@aws-sdk/client-apigatewaymanagementapi';
import { marshall, unmarshall } from '@aws-sdk/util-dynamodb';
import { DynamoDBClient, GetItemCommand } from '@aws-sdk/client-dynamodb';

/**
 * The SNS client.
 */
const snsClient = new SNSClient();

/**
 * The DynamoDB client.
 */
const client = new DynamoDBClient();

/**
 * The API Gateway Management API client.
 */
let apiGatewayManagementApiClient: ApiGatewayManagementApiClient;

const main = HandleDelivery(async (event: AWSLambda.APIGatewayEvent) => {
  const { url, team } = JSON.parse(event.body!);
  const { me } = await getCurrentUser(event);

  /**
   * Create a new API Gateway Management API client.
   */
  if (!apiGatewayManagementApiClient) {
    apiGatewayManagementApiClient = new ApiGatewayManagementApiClient({
      endpoint: `https://${process.env.WEBSOCKET_API_FQDN}/prod`,
    });
  }

  /**
   * Generate a new UUID.
   */
  const uuid = randomUUID();

  /**
   * Create new heartbeat records.
   */
  const mobile = await DalClient.createPulse(team, 3, uuid, url, 1, me.username, 0, 0);
  const desktop = await DalClient.createPulse(team, 3, uuid, url, 1, me.username, 1, 0);

  /**
   * Trigger the new heartbeat records.
   */
  const mobileCommand = new PublishCommand({
    Message: JSON.stringify({ url, uuid, mode: 'mobile' }),
    TopicArn: process.env.TRIGGER_TOPIC_ARN,
  });
  const desktopCommand = new PublishCommand({
    Message: JSON.stringify({ url, uuid, mode: 'desktop' }),
    TopicArn: process.env.TRIGGER_TOPIC_ARN,
  });
  await snsClient.send(mobileCommand);
  await snsClient.send(desktopCommand);

  /**
   * Broadcast the new metrics to all connections.
   */
  const teamParams = {
    TableName: process.env.CACHE_TABLE_NAME,
    Key: marshall({
      sub: team.toString(),
      type: 'teamConnections',
    }),
  };

  const getTeamCommand = new GetItemCommand(teamParams);
  const getTeamResponse = await client.send(getTeamCommand);
  const teamRecord = unmarshall(getTeamResponse.Item!);

  const connections = teamRecord.connections || [];
  for (const connection of connections) {
    try {
      const params = {
        ConnectionId: connection,
        Data: Buffer.from(JSON.stringify({ action: 'REFRESH_EXECUTIONS_TABLE' })),
      };
      await apiGatewayManagementApiClient.send(new PostToConnectionCommand(params));
      console.log(`Sent message to connection ${connection}`);
    } catch (error) {
      console.error(`Failed to send message to connection ${connection}`, error);
    }
  }

  /**
   * Return the response.
   */
  return { mobile, desktop };
});

export { main };
