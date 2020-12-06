import 'package:examen_3/ServicioOB.dart';
import 'package:flutter/material.dart';
import 'package:examen_3/RegistroServicio.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart' show Future;
import 'dart:convert';
import 'package:json_table/json_table.dart';

class ListadoServicio extends StatefulWidget {
  String titulo;
  List<ServicioOB> oListaServicios = [];
  int codigoServicioSeleccionado = 0;
  String urlGeneral = "http://movilesii202022.somee.com";
  String urlController = "/Servicios/";
  String urlListado = "/Listar?NombreCliente=";
  String urlXCodigo = "/Listar?CodigoServicio=";
  String jSonServicios =
      '[{"CodigoServicio": 0,"NombreCliente":"","NumeroOrdenServicio":"","FechaProgramada":"","Linea":"","Estado":"","Observaciones":"","Eliminado":false,"CodigoError":0,"DescripcionError":"","MensajeError":null}]';

  ListadoServicio(this.titulo);
  @override
  State<StatefulWidget> createState() => _ListadoServicio();
}

class _ListadoServicio extends State<ListadoServicio> {
  final _tfNombreCliente = TextEditingController();
  final _tfCodigoServicio = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  Future<String> _consultarServicios() async {
    String urlListaServicios = widget.urlGeneral +
        widget.urlController +
        widget.urlListado +
        _tfNombreCliente.text.toString();

    var respuesta = await http.get(urlListaServicios);
    var data = respuesta.body;
    var oListaServicioTmp = List<ServicioOB>.from(
        json.decode(data).map((x) => ServicioOB.fromJson(x)));

    setState(() {
      widget.oListaServicios = oListaServicioTmp;
      widget.jSonServicios = data;

      if (widget.oListaServicios.length == 0) {
        widget.jSonServicios =
            '[{"CodigoServicio":0,"NombreCliente":"","NumeroOrdenServicio":"","FechaProgramada":"","Linea":"","Estado":"","Observaciones":"","Eliminado":false,"CodigoError":0,"DescripcionError":"","MensajeError":null}]';
      }
    });

    return "Procesado";
  }

  Future<String> _consultarXCodigo() async {
    String urlListaXCodigo = widget.urlGeneral +
        widget.urlController +
        widget.urlXCodigo +
        _tfCodigoServicio.text.toString();

    var respuesta = await http.get(urlListaXCodigo);
    var data = respuesta.body;
    var oListaServicioTmp = List<ServicioOB>.from(
        json.decode(data).map((x) => ServicioOB.fromJson(x)));

    setState(() {
      widget.oListaServicios = oListaServicioTmp;
      widget.jSonServicios = data;

      if (widget.oListaServicios.length == 0) {
        widget.jSonServicios =
            '[{"CodigoServicio":0,"NombreCliente":"","NumeroOrdenServicio":"","FechaProgramada":"","Linea":"","Estado":"","Observaciones":"","Eliminado":false,"CodigoError":0,"DescripcionError":"","MensajeError":null}]';
      }
    });

    return "Procesado";
  }

  void _funciones() {
    _consultarServicios();
    _consultarXCodigo();
  }

  void _registraServicio() {
    Navigator.of(context)
        .push(new MaterialPageRoute<Null>(builder: (BuildContext pContexto) {
      return new RegistroServicio("", widget.codigoServicioSeleccionado);
    }));
  }

  void _verRegistroServicio() {}

  @override
  Widget build(BuildContext context) {
    var json = jsonDecode(widget.jSonServicios);
    return Scaffold(
        appBar: AppBar(
          title: Text("Consulta de Servicios"),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextField(
                controller: _tfNombreCliente,
                decoration: InputDecoration(
                  labelText: "Cliente",
                ),
              ),
              TextField(
                controller: _tfCodigoServicio,
                decoration: InputDecoration(
                  labelText: "Código Orden",
                ),
              ),
              Text(
                "Se encontraron " +
                    widget.oListaServicios.length.toString() +
                    " Servicios",
                style: TextStyle(fontSize: 9),
              ),
              new Table(children: [
                TableRow(children: [
                  Container(
                    padding: EdgeInsets.only(right: 10.0),
                    child: RaisedButton(
                      color: Colors.greenAccent,
                      child: Text(
                        "Consultar",
                        style: TextStyle(fontSize: 10, fontFamily: "rbold"),
                      ),
                      onPressed: _funciones,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10.0),
                    child: RaisedButton(
                      color: Colors.greenAccent,
                      child: Text(
                        "Nuevo",
                        style: TextStyle(fontSize: 10, fontFamily: "rbold"),
                      ),
                      onPressed: _registraServicio,
                    ),
                  )
                ])
              ]),
              JsonTable(
                json,
                showColumnToggle: true,
                allowRowHighlight: true,
                rowHighlightColor: Colors.yellow[500].withOpacity(0.7),
                paginationRowCount: 10,
                onRowSelect: (index, map) {
                  widget.codigoServicioSeleccionado =
                      int.parse(map["CodigoServicio"].toString());

                  Navigator.of(context).push(new MaterialPageRoute<Null>(
                      builder: (BuildContext pContexto) {
                    return new RegistroServicio(
                        "", widget.codigoServicioSeleccionado);
                  }));
                  print(widget.codigoServicioSeleccionado);
                  _verRegistroServicio();
                },
              ),
            ],
          ),
        ));
  }
}
