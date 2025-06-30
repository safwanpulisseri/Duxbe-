grant USAGE on schema public to public;

grant all on schema public to public;


create trigger on_auth_user_created
after insert on auth.users for each row
execute function handle_new_user ();