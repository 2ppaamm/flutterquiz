enum SubscriptionTier {
  free,           // 5 lives, ads
  simba,          // SIMBA partnership
  student,        // $15/month or $120/year
  family,         // $25/month or $960/year (4 members)
  teacher,        // $1200/year (8 students)
  school,         // $12000/year (100 students + 5 teachers)
}

class UserSubscription {
  final SubscriptionTier tier;
  final DateTime? subscriptionEnd;
  final int consumableLives;
  final bool hasUnlimitedLives;
  final List<String> childProfiles;
  final String? schoolId;
  
  UserSubscription({
    required this.tier,
    this.subscriptionEnd,
    this.consumableLives = 0,
    this.hasUnlimitedLives = false,
    this.childProfiles = const [],
    this.schoolId,
  });
  
  bool get isActive {
    if (tier == SubscriptionTier.free) return true;
    if (subscriptionEnd == null) return false;
    return DateTime.now().isBefore(subscriptionEnd!);
  }
  
  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.toString() == 'SubscriptionTier.${json['tier']}',
        orElse: () => SubscriptionTier.free,
      ),
      subscriptionEnd: json['subscription_end'] != null
          ? DateTime.parse(json['subscription_end'])
          : null,
      consumableLives: json['consumable_lives'] ?? 0,
      hasUnlimitedLives: json['has_unlimited_lives'] ?? false,
      childProfiles: List<String>.from(json['child_profiles'] ?? []),
      schoolId: json['school_id'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'tier': tier.toString().split('.').last,
      'subscription_end': subscriptionEnd?.toIso8601String(),
      'consumable_lives': consumableLives,
      'has_unlimited_lives': hasUnlimitedLives,
      'child_profiles': childProfiles,
      'school_id': schoolId,
    };
  }
}