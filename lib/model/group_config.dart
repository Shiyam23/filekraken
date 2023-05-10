class GroupConfig {

  GroupConfig({
    required this.groups
  });

  final List<GroupOption> groups;
}

class GroupOption {

  GroupOption({
    this.match,
    this.groupName
  });

  String? match;
  String? groupName;
}