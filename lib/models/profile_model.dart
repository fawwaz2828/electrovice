class ProfileData {
  const ProfileData({
    required this.fullName,
    required this.emailAddress,
    required this.mobileNumber,
    required this.isMobileVerified,
    required this.primaryNodes,
    required this.securityOptions,
    this.avatarUrl,
  });

  final String fullName;
  final String emailAddress;
  final String mobileNumber;
  final bool isMobileVerified;
  final String? avatarUrl;
  final List<ProfileNode> primaryNodes;
  final List<SecurityOption> securityOptions;

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    final List<dynamic> nodes = map['primaryNodes'] as List<dynamic>? ?? [];
    final List<dynamic> security =
        map['securityOptions'] as List<dynamic>? ?? [];

    return ProfileData(
      fullName: map['fullName'] as String? ?? '',
      emailAddress: map['emailAddress'] as String? ?? '',
      mobileNumber: map['mobileNumber'] as String? ?? '',
      isMobileVerified: map['isMobileVerified'] as bool? ?? false,
      avatarUrl: map['avatarUrl'] as String?,
      primaryNodes: nodes
          .whereType<Map>()
          .map(
            (node) => ProfileNode.fromMap(
              Map<String, dynamic>.from(node as Map<dynamic, dynamic>),
            ),
          )
          .toList(),
      securityOptions: security
          .whereType<Map>()
          .map(
            (option) => SecurityOption.fromMap(
              Map<String, dynamic>.from(option as Map<dynamic, dynamic>),
            ),
          )
          .toList(),
    );
  }

  ProfileData copyWith({
    String? fullName,
    String? emailAddress,
    String? mobileNumber,
    bool? isMobileVerified,
    String? avatarUrl,
    List<ProfileNode>? primaryNodes,
    List<SecurityOption>? securityOptions,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      emailAddress: emailAddress ?? this.emailAddress,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      isMobileVerified: isMobileVerified ?? this.isMobileVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      primaryNodes: primaryNodes ?? this.primaryNodes,
      securityOptions: securityOptions ?? this.securityOptions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'emailAddress': emailAddress,
      'mobileNumber': mobileNumber,
      'isMobileVerified': isMobileVerified,
      'avatarUrl': avatarUrl,
      'primaryNodes': primaryNodes.map((node) => node.toMap()).toList(),
      'securityOptions':
          securityOptions.map((option) => option.toMap()).toList(),
    };
  }

  factory ProfileData.sample() {
    return const ProfileData(
      fullName: 'Alex Johnson',
      emailAddress: 'alex.johnson@gmail.com',
      mobileNumber: '+1 (555) 012-3456',
      isMobileVerified: true,
      primaryNodes: [
        ProfileNode(
          type: 'home',
          title: 'Home Base',
          subtitle: '241 Oak Ridge, Ste 402 North\nHills, CA 91343',
        ),
        ProfileNode(
          type: 'hq',
          title: 'Headquarters',
          subtitle: 'Tech Plaza, Building B, Floor 12',
        ),
      ],
      securityOptions: [
        SecurityOption(
          key: 'change_access_key',
          title: 'Change Access Key',
        ),
        SecurityOption(
          key: 'privacy_management',
          title: 'Privacy Management',
        ),
      ],
    );
  }
}

class ProfileNode {
  const ProfileNode({
    required this.type,
    required this.title,
    required this.subtitle,
  });

  final String type;
  final String title;
  final String subtitle;

  factory ProfileNode.fromMap(Map<String, dynamic> map) {
    return ProfileNode(
      type: map['type'] as String? ?? 'custom',
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'subtitle': subtitle,
    };
  }
}

class SecurityOption {
  const SecurityOption({
    required this.key,
    required this.title,
  });

  final String key;
  final String title;

  factory SecurityOption.fromMap(Map<String, dynamic> map) {
    return SecurityOption(
      key: map['key'] as String? ?? '',
      title: map['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'title': title,
    };
  }
}
