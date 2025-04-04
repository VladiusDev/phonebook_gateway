class Employee {
  final String name;
  final String nameLower;
  final String tel;
  final String organization;

  Employee(
      {required this.name,
      required this.nameLower,
      required this.tel,
      required this.organization});

  Map<String, dynamic> toMap() {
    return {
      'employee': name,
      'employee_lower': nameLower,
      'tel': tel,
      'organization': organization,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      name: map['employee'] as String,
      nameLower: map['employee_lower'] as String,
      tel: map['tel'] as String,
      organization: map['organization'] as String,
    );
  }
}
