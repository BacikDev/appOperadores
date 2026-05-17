class Event {
  final int id;
  final String name;
  final String image;
  final String date;
  final String hour;
  final String channel;

  const Event ({
    required this.id,
    required this.name,
    required this.image,
    required this.date,
    required this.hour,
    required this.channel,
  });

  factory Event.fromJson(Map<String,dynamic> json)=>Event(
    id: json['id'], name: json['name'], image: json['image'], date: json['date'], hour: json['hour'], channel: json['channel'],);

    Map<String,dynamic> toJson()=>{
      'id': id,
      'name': name,
      'date': date,
      'hour': hour,
      'channel': channel,
    };

    Event copy() => Event(id: id, name: name, image: image, date: date, hour: hour, channel: channel);
}