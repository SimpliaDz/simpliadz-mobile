class CurrentUser {
  const CurrentUser({
    required this.id,
    required this.email,
    required this.roles,
    required this.permissions,
  });

  final String id;
  final String email;
  final List<String> roles;
  final List<String> permissions;
}
