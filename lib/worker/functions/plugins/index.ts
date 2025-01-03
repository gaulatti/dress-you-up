import { Stack } from 'aws-cdk-lib';
import { IVpc, SecurityGroup } from 'aws-cdk-lib/aws-ec2';
import { Cluster, FargateTaskDefinition } from 'aws-cdk-lib/aws-ecs';
import { IRole } from 'aws-cdk-lib/aws-iam';
import { Bucket } from 'aws-cdk-lib/aws-s3';
import { Topic } from 'aws-cdk-lib/aws-sns';
import { createAutobahnStorageLambda } from './delivery';
import { createAutobahnLighthouseProviderLambda } from './provider';
import { createAdHocTriggerLambda } from './trigger';

const createPlugins = (
  stack: Stack,
  startPlaylistTopic: Topic,
  updatePlaylistTopic: Topic,
  serviceRole: IRole,
  fargateTaskDefinition: FargateTaskDefinition,
  cluster: Cluster,
  observabilityBucket: Bucket,
  securityGroup: SecurityGroup,
  vpc: IVpc
) => {
  /**
   * Trigger
   */
  const { adhocTriggerLambda } = createAdHocTriggerLambda(stack, startPlaylistTopic, serviceRole);

  /**
   * Provider
   */
  const { lighthouseProviderLambda } = createAutobahnLighthouseProviderLambda(
    stack,
    updatePlaylistTopic,
    serviceRole,
    fargateTaskDefinition,
    cluster,
    observabilityBucket,
    vpc,
    securityGroup
  );

  /**
   * Delivery
   */
  const { autobahnStorageLambda } = createAutobahnStorageLambda(stack, updatePlaylistTopic, serviceRole);

  return { lighthouseProviderLambda };
};

export { createPlugins };
