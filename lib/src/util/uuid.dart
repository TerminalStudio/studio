import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String uuidV4() => _uuid.v4();
