import { Stack, StackProps } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { createCommonInfrastructure } from './common';
import { createObservabilityInfrastructure } from './observability';
import { createWorkerInfrastructure } from './worker';

/**
 * Represents the DressYouUpStack class.
 * This class extends the Stack class and is responsible for creating the DressYouUp stack.
 */
class DressYouUpStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    /**
     * Create the common infrastructure. This is shared between server and worker.
     */
    const { triggerTopic, vpc, securityGroup, cluster, eip } = createCommonInfrastructure(this);

    /**
     * Create Observability Infrastructure
     */
    const { observabilityBucket } = createObservabilityInfrastructure(this, triggerTopic);

    /**
     * Create the worker infrastructure
     */
    createWorkerInfrastructure(this, securityGroup, cluster, observabilityBucket, triggerTopic);
  }
}

export { DressYouUpStack };
