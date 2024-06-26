import { CfnOutput, Duration, Stack } from 'aws-cdk-lib';
import { SecurityGroup, SubnetType, Vpc } from 'aws-cdk-lib/aws-ec2';
import { FargateService } from 'aws-cdk-lib/aws-ecs';
import {
  ApplicationLoadBalancer,
  ApplicationProtocol,
  ApplicationTargetGroup,
  ListenerAction,
  Protocol,
  TargetType,
} from 'aws-cdk-lib/aws-elasticloadbalancingv2';

/**
 * Creates a Lighthouse Load Balancer.
 *
 * @param stack - The CloudFormation stack.
 * @param service - The Fargate service.
 * @param vpc - The VPC.
 * @param securityGroup - The security group.
 * @returns The created load balancer.
 */
const createLoadBalancer = (stack: Stack, service: FargateService, vpc: Vpc, securityGroup: SecurityGroup) => {
  /**
   * Create the Load Balancer
   */
  const loadBalancer = new ApplicationLoadBalancer(stack, `${stack.stackName}ServerLoadBalancer`, {
    loadBalancerName: `${stack.stackName}Server`,
    vpc: vpc,
    internetFacing: true,
    vpcSubnets: {
      subnetType: SubnetType.PUBLIC,
    },
    securityGroup,
  });

  /**
   * Create the Target Group which will handle the requests
   */
  const targetGroup = new ApplicationTargetGroup(stack, `${stack.stackName}ServerTargetGroup`, {
    targetGroupName: `${stack.stackName}Server`,
    vpc,
    targetType: TargetType.IP,
    protocol: ApplicationProtocol.HTTP,
    port: 80,
    healthCheck: {
      protocol: Protocol.HTTP,
      path: '/',
      interval: Duration.seconds(30),
      timeout: Duration.seconds(5),
      healthyThresholdCount: 2,
      unhealthyThresholdCount: 2,
      healthyHttpCodes: '200,401,302',
    },
    targets: [service],
  });

  /**
   * This listener for the Load Balancer will handle all HTTPS traffic
   */
  loadBalancer.addListener(`${stack.stackName}ServerListener`, {
    port: 80,
    defaultAction: ListenerAction.forward([targetGroup]),
  });

  /**
   * Export the DNS name of the Load Balancer
   */
  new CfnOutput(stack, `${stack.stackName}ServerLoadBalancerDNS`, {
    value: loadBalancer.loadBalancerDnsName,
    description: 'The DNS name of the load balancer',
    exportName: `${stack.stackName}LoadBalancerDNS`,
  });

  return { loadBalancer };
};

export { createLoadBalancer };
