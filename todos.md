# Manual Setup Todos

## Supabase: Account Deletion RPC Function

When using Supabase as your backend, you need to create a PostgreSQL function so users can delete their own auth accounts from the client. Run this SQL in the Supabase SQL Editor:

```sql
CREATE OR REPLACE FUNCTION public."deleteUser"()
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
  DELETE FROM auth.users WHERE id = auth.uid();
$$;
```

This is called by `SupabaseAuthService.deleteAccount()` via `supabase.rpc('deleteUser')`.

## Firebase: Recent Authentication for Account Deletion

`FirebaseAuth.currentUser.delete()` requires the user to have signed in recently. If the user's session is old, Firebase will throw a `requires-recent-login` error. For production apps, you may want to add a re-authentication step before deletion. See: https://firebase.google.com/docs/auth/flutter/manage-users#re-authenticate_a_user
