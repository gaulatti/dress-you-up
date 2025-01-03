import { Stack } from 'aws-cdk-lib';
import { IVpc } from 'aws-cdk-lib/aws-ec2';
import { Cluster } from 'aws-cdk-lib/aws-ecs';

/**
 * Creates a cluster using the provided stack and VPC.
 * @param stack - The stack to create the cluster in.
 * @param vpc - The VPC to associate with the cluster.
 * @returns An object containing the created cluster.
 */
const createCluster = (stack: Stack, vpc: IVpc) => {
  const cluster = new Cluster(stack, `${stack.stackName}CommonCluster`, {
    clusterName: `${stack.stackName}Common`,
    vpc,
  });

  return { cluster };
};

export { createCluster };
