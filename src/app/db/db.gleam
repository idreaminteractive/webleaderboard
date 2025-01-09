pub opaque type DBConnection {
  DBConnection(dsn: String)
}

pub fn new(dsn: String) -> DBConnection {
  // connect + deal
  DBConnection(dsn)
}

pub fn close(conn: DBConnection) {
  todo
}
