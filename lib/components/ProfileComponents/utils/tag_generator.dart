List<String> generateIdentityTags({
  required List<String> activities,
  required Set<String> vibes,
  int? scheduleDensity,
  int? planningStyle,
}) {
  final tags = <String>{}; // use a Set to avoid duplicates

  // Activity-based tags
  if (activities.contains('Sports & fitness')) {
    tags.addAll(['🏃‍♂️ Active Adventurer', '💪 Gym Rat']);
  }
  if (activities.contains('Music & nightlife')) {
    tags.addAll(['🎶 Nightlife Navigator', '🎤 Stage Side']);
  }
  if (activities.contains('Learning & workshops')) {
    tags.addAll(['🧠 Curious Learner', '📚 Knowledge Seeker']);
  }
  if (activities.contains('Food & dining')) {
    tags.addAll(['🍜 Food Explorer', '🍣 Culinary Explorer']);
  }
  if (activities.contains('Community service')) {
    tags.addAll(['❤️ Community Builder', '🤝 Local Helper']);
  }
  if (activities.contains('Outdoor adventures')) {
    tags.addAll(['🌲 Nature Seeker', '🧗 Trail Explorer']);
  }
  if (activities.contains('Arts & culture')) {
    tags.add('🖼️ Culture Curator');
  }
  if (activities.contains('Tech & gaming')) {
    tags.add('🎮 Digital Nomad');
  }

  // Vibe-based tags
  if (vibes.contains('High Energy Party')) {
    tags.addAll(['🍹 Bar Hopper', '🔥 Scene Starter']);
  }
  if (vibes.contains('Intimate Gatherings')) {
    tags.addAll(['🛋️ Cozy Companion', '🫶 Inner Circle']);
  }
  if (vibes.contains('Creative & Artistic')) {
    tags.addAll(['🎨 Artsy Soul', '🧵 Visual Storyteller']);
  }
  if (vibes.contains('Chill & Relaxed')) {
    tags.add('🌊 Laid-back Cruiser');
  }
  if (vibes.contains('Intellectual & Cultural')) {
    tags.add('🧠 Deep Diver');
  }
  if (vibes.contains('Food & Culinary')) {
    tags.add('🍽️ Flavor Chaser');
  }
  if (vibes.contains('Adventure & Outdoors')) {
    tags.add('🏕️ Weekend Warrior');
  }

  // Schedule density
  if ((scheduleDensity ?? 3) >= 4) tags.add('⚡ Always On');
  if ((scheduleDensity ?? 3) <= 2) tags.add('😌 Chill Planner');
  if ((scheduleDensity ?? 3) == 5) tags.add('📅 Maxed Out');
  if ((scheduleDensity ?? 3) == 3) tags.add('🧘 Balanced Seeker');
  if ((scheduleDensity ?? 3) == 1) tags.add('🧘‍♂️ Zen Master');

  // Planning style
  if ((planningStyle ?? 1) == 0) {
    tags.addAll(['🚶 Walkable Explorer', '🚶 Strolls Preferred']);
  }
  if ((planningStyle ?? 1) == 1) {
    tags.add('🗺️ Local Hopper');
  }
  if ((planningStyle ?? 1) == 2) {
    tags.addAll(['🚗 Will Travel', '🛣️ Destination Finder']);
  }

  return tags.take(5).toList(); // return only 5 tags for UI
}
