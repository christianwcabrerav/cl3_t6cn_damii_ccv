import 'package:flutter/material.dart';
import 'package:examen_3/ServicioOB.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart' show Future;
import 'dart:convert';
import 'package:json_table/json_table.dart';

class RegistroServicio extends StatefulWidget {
  String titulo;
  ServicioOB oServicio = ServicioOB();
  int codigoServicioSeleccionado = 0;
  String urlGeneral = "http://movilesii202022.somee.com";
  String urlController = "/Servicios/";
  String urlListarkey = "Listarkey?pcodigoServicio=";
  String urlRegistraModifica = "RegistraModifica?";

  String mensaje = "";
  bool validacion = false;

  RegistroServicio(this.titulo, this.codigoServicioSeleccionado);

  @override
  _RegistroServicio createState() => _RegistroServicio();
}

class _RegistroServicio extends State<RegistroServicio> {
  final _tfCliente = TextEditingController();
  final _tfNroOrden = TextEditingController();
  final _tfFecha = TextEditingController();
  final _tfLinea = TextEditingController();
  final _tfEstado = TextEditingController();
  final _tfObservaciones = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.oServicio.inicializar();
    if (widget.codigoServicioSeleccionado > 0) {
      _listarKey();
    }
  }

  Future<String> _listarKey() async {
    String urlListaServicios = widget.urlGeneral +
        widget.urlController +
        widget.urlListarkey +
        widget.codigoServicioSeleccionado.toString();
    print(urlListaServicios);
    var respuesta = await http.get(urlListaServicios);

    setState(() {
      widget.oServicio = ServicioOB.fromJson(json.decode(respuesta.body));
      if (widget.oServicio.CodigoServicio > 0) {
        widget.mensaje = "Estás actualizando los datos";
        _mostrarDatos();
      }
      print(widget.oServicio);
    });
    return "Procesado";
  }

  void _mostrarDatos() {
    _tfCliente.text = widget.oServicio.NombreCliente;
    _tfNroOrden.text = widget.oServicio.NumeroOrdenServicio;
    _tfFecha.text = widget.oServicio.FechaProgramada;
    _tfLinea.text = widget.oServicio.Linea;
    _tfEstado.text = widget.oServicio.Estado;
    _tfObservaciones.text = widget.oServicio.Observaciones;
  }

  bool _validarRegistro() {
    if (_tfCliente.text.toString() == "" || _tfNroOrden.text.toString() == "") {
      widget.validacion = false;
      setState(() {
        widget.mensaje = "Falta completar los campos obligatorios";
      });
      return false;
    }
    return true;
  }

  void _grabarRegistro() {
    if (_validarRegistro()) {
      _ejecutarServicioGrabado();
    }
  }

  Future<String> _ejecutarServicioGrabado() async {
    String accion = "N";

    if (widget.oServicio.CodigoServicio > 0) {
      accion = "A";
    }

    String strParametros = "";
    strParametros += "Accion=" + accion;
    strParametros +=
        "&CodigoServicio" + widget.oServicio.CodigoServicio.toString();
    strParametros += "&NombreCliente=" + _tfCliente.text;
    strParametros += "&NumeroOrdenServicio=" + _tfNroOrden.text;
    strParametros += "&Fechaprogramada=" + _tfFecha.text;
    strParametros += "&Linea=" + _tfLinea.text;
    strParametros += "&Estado=" + _tfEstado.text;
    strParametros += "&Observaciones=" + _tfObservaciones.text;

    String urlRegistroServicios = "";
    urlRegistroServicios = widget.urlGeneral +
        widget.urlController +
        widget.urlRegistraModifica +
        strParametros;

    var respuesta = await http.get(urlRegistroServicios);
    var data = respuesta.body;
    setState(() {
      widget.oServicio = ServicioOB.fromJson(json.decode(data));
      if (widget.oServicio.CodigoServicio > 0) {
        widget.mensaje = "Grabado Correctamente";
      }
      print(widget.oServicio);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Registro de Servicio" + widget.titulo),
        ),
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Text(" Código de Servicio: " +
                  widget.oServicio.CodigoServicio.toString()),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Column(
                children: <Widget>[
                  TextField(
                      controller: _tfCliente,
                      decoration: InputDecoration(
                        hintText: "Ingresar Cliente",
                        labelText: "Cliente",
                        errorText: _tfCliente.text.toString() == ""
                            ? "Falta ingresar el Cliente "
                            : null,
                      )),
                  TextField(
                      controller: _tfNroOrden,
                      decoration: InputDecoration(
                        hintText: "Ingresar Nro. Orden",
                        labelText: "Nro. de Orden",
                        errorText: _tfNroOrden.text.toString() == ""
                            ? "Falta ingresar Número de Orden "
                            : null,
                      )),
                  TextField(
                      controller: _tfFecha,
                      decoration: InputDecoration(
                        hintText: "Ingresar Fecha",
                        labelText: "Fecha",
                      )),
                  TextField(
                      controller: _tfLinea,
                      decoration: InputDecoration(
                        hintText: "Ingresar Línea",
                        labelText: "Línea",
                      )),
                  TextField(
                      controller: _tfEstado,
                      decoration: InputDecoration(
                        hintText: "Ingresar Estado",
                        labelText: "Estado",
                      )),
                  TextField(
                      controller: _tfObservaciones,
                      decoration: InputDecoration(
                        hintText: "Ingresar Observaciones",
                        labelText: "Observaciones",
                      )),
                  RaisedButton(
                    color: Colors.greenAccent,
                    child: Text(
                      "Grabar",
                      style: TextStyle(fontSize: 18, fontFamily: "rbold"),
                    ),
                    onPressed: _grabarRegistro,
                  ),
                  Text("Mensaje: " + widget.mensaje),
                ],
              ),
            )
          ],
        ));
  }
}
