import { Stack } from 'aws-cdk-lib';
import { Table } from 'aws-cdk-lib/aws-dynamodb';
import { IVpc, SecurityGroup } from 'aws-cdk-lib/aws-ec2';
import { Cluster } from 'aws-cdk-lib/aws-ecs';
import { IRole } from 'aws-cdk-lib/aws-iam';
import { Bucket } from 'aws-cdk-lib/aws-s3';
import { Topic } from 'aws-cdk-lib/aws-sns';
import { createFargateTask } from './fargate';
import { createPlugins } from './functions/plugins';

/**
 * Creates the worker infrastructure.
 *
 * @param stack - The AWS CloudFormation stack.
 */
const createWorkerInfrastructure = (
  stack: Stack,
  vpc: IVpc,
  startPlaylistTopic: Topic,
  updatePlaylistTopic: Topic,
  cacheTable: Table,
  observabilityBucket: Bucket,
  serviceRole: IRole,
  cluster: Cluster,
  securityGroup: SecurityGroup
) => {
  /**
   * Create Fargate Service
   *
   * Important: This needs to be deployed from a x64 machine (e.g. EC2) because the Docker image is built for x64.
   *
   * Chrome is not available for ARM64 yet in a headless mode, so we're forced to use x64. This is a limitation of the
   * current version of Chrome.
   *
   * Said that, this can be directly deployed by CLI from local if the computer is x64. Hence, it'll be needed to
   * create a CodeBuild Project and deploy this CDK project from there.
   */
  const { fargateTaskDefinition } = createFargateTask(stack, observabilityBucket);

  /**
   * Plugins
   */
  const { lighthouseProviderLambda } = createPlugins(
    stack,
    startPlaylistTopic,
    updatePlaylistTopic,
    serviceRole,
    fargateTaskDefinition,
    cluster,
    observabilityBucket,
    securityGroup,
    vpc
  );

  /**
   * Add environment variables to the Fargate task definition
   */
  lighthouseProviderLambda.grantInvoke(fargateTaskDefinition.taskRole);
  fargateTaskDefinition.grantRun(lighthouseProviderLambda);

  return { observabilityBucket, cacheTable, fargateTaskDefinition };
};

export { createWorkerInfrastructure };
