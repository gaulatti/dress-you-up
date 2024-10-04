import { HandleDelivery } from '../../../../common/utils/api';
import { DalClient } from '../../dal/client';
import { ListRenderingParams } from '../../dal/types';

/**
 * Handles the main logic for the API endpoint that lists targets.
 *
 * @param event - The AWS API Gateway event object.
 * @returns A Promise that resolves to the API Gateway response.
 */
const main = HandleDelivery(async (event: AWSLambda.APIGatewayEvent) => {
  const renderingParams: ListRenderingParams = event.queryStringParameters?.startRow
    ? (event.queryStringParameters as unknown as ListRenderingParams)
    : {
        startRow: '0',
        endRow: '100',
        sort: '',
        filters: '{}',
      };

  const output = { targets: await DalClient.listTargets(renderingParams) };

  return output;
});

export { main };