import { InvokeCommand, LambdaClient } from '@aws-sdk/client-lambda';
import jwt from 'jsonwebtoken';
import { ENUMS } from '../../../common/utils/consts';

/**
 * Represents a decoder for decoding binary data.
 */
const decoder = new TextDecoder('utf-8');

/**
 * Represents a client for interacting with the Lambda service.
 */
const lambdaClient = new LambdaClient();

/**
 * The main function for the kickoff event.
 *
 * @param event - The event object containing the field, sub, and arguments.
 * @returns An object with the kickoff information.
 */
const main = async (event: AWSLambda.APIGatewayEvent) => {
  // TODO: Move this to a common util function.
  const token = event.headers.Authorization!.split(' ')[1];
  const {
    payload: { sub },
  } = jwt.decode(token, { complete: true })!;

  // TODO: Move this to a common util function.
  const allowedOrigins = ['http://localhost:5173', `https://${process.env.FRONTEND_FQDN}`];
  const origin = event.headers.origin || '';

  const invokeCommand = new InvokeCommand({
    FunctionName: process.env.KICKOFF_CACHE_ARN,
    Payload: JSON.stringify({ sub }),
  });

  const { Payload }  = await lambdaClient.send(invokeCommand);
  const me = JSON.parse(decoder.decode(Payload));

  const output = {
    enums: ENUMS,
    me,
    features: [],
  };

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Origin': allowedOrigins.includes(origin) ? origin : '',
      'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
    },
    body: JSON.stringify(output),
  };
};

export { main };
