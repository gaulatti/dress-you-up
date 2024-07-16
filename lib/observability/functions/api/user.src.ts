import { DalClient } from '../dal/client';
/**
 * The main function for the user type.
 *
 * @param event - The event object containing the field, sub, and arguments.
 * @returns An object with the user information.
 */
const main = async (event: { field: string; source: any; sub: string; arguments: Record<string, string>; parentType: string }) => {
  const { field, source } = event;

  switch (field) {
    case 'memberships':
      return { memberships: await DalClient.listMembershipsByUser(source.id) };

    default:
      throw new Error(`Unknown field: ${field}`);
  }
};

export { main };