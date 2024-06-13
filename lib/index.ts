import { Stack, StackProps } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { createCluster } from './compute';
import { createFargateTask } from './fargate';
import { createTriggerLambda } from './functions/trigger';
import { createSecurityGroup, createVpc } from './network';
import { createSecrets } from './secrets';

class DressYouUpStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    /**
     * Create Secrets
     */
    const { urlSecret, apiKeySecret, targetSecret } = createSecrets(this);

    /**
     * Create VPC
     */
    const { vpc } = createVpc(this);

    /**
     * Create Security Group
     */
    const { securityGroup } = createSecurityGroup(this, vpc);

    /**
     * Create Cluster
     */
    const { cluster } = createCluster(this, vpc);

    /**
     * Create Fargate Service
     */
    const { fargateTaskDefinition } = createFargateTask(this);

    /**
     * Create Trigger Lambda
     */
    const triggerLambda = createTriggerLambda(this, { urlSecret, apiKeySecret, targetSecret }, fargateTaskDefinition, cluster, securityGroup);
  }
}

export { DressYouUpStack };