class AuthEntitie {
  final String? uuid;
  final String? correo;
  final String? contrasena;
  final dynamic persona;
  final dynamic userOrAdmin;
  final String? token;

  AuthEntitie({
     this.uuid,
     this.correo,
     this.contrasena,
    this.persona,
    this.userOrAdmin,
    this.token,
  });
}