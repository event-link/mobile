enum LogLevel {
  Debug, // DEBUG: Additional information about application behavior for cases when that information is necessary to diagnose problems.
  Info, // INFO:  Application events for general purposes.
  Warn, // WARN:  Application events that may be an indication of a problem.
  Error, // ERROR: Typically logged in the catch block a try/catch block, includes the exception and contextual data.
  Fatal, // FATAL: A critical error that results in the termination of an application.
  Trace // TRACE: Used to mark the entry and exit of functions, for purposes of performance profiling.
}

enum LogDb {
  System,
  /* Logs everything that is related to the system */
  Event,
  /* Logs everything related to events (Crawler, fetching of events, etc.) */
  Payment,
  /* Logs everything related to payments (Orders, etc.) */
  User,
  /* Logs everything related to users (User updates, authentication, etc) */
  Statistics, /* Logs everything related to statistics (Crawler statistics, user auth tries, user activity, etc.) */
}

class LogInput {
  LogDb logDb;
  String parentName;
  String functionName;
  String message;
  LogLevel logLevel;

  LogInput(
      {this.logDb,
      this.parentName,
      this.functionName,
      this.message,
      this.logLevel});

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['logDb'] = logDb;
    map['parentName'] = parentName;
    map['functionName'] = functionName;
    map['message'] = message;
    map['logLevel'] = logLevel;
    return map;
  }
}
