import 'package:flutter/foundation.dart';

class AppData {

  // INFO DEL PACIENTE

  static String idPaciente = '';
  static String tipoDocumento = '';
  static String documentoIdentidad = '';
  static String nombrePaciente = '';
  static String correoElectronico = '';
  static String? celular;
  static String? perfil;
  static String eps = '';
  static String? ciudad;
  static String sede = '';

  // INFO AUTORIZACION EN VIGENCIA

  static String? autorizacionId;
  static String? numeroAutorizacion;
  static String? fechaInicio;
  static String? fechaFinal;
  static String? fechaInicior;
  static String? fechaFinalr;
  static String? paquete;
  static String? codeContract;
  static String? codePlan;
  static String? codeRegimen;
  static String? codeTypeAffiliate;
  static String? codeLevelAffiliate;
  static String examen = '';
  static String? cantidad;
  static String? sede_agenda;


  static String nombreServicio(dynamic tipo) {
    final Map<int, String> arrayServicios = {
      2: 'PSIQUIATRÍA PEDIATRICA PRESENCIAL PROGRAMA',
      5: 'ADMINISTRACIÓN DE PRUEBA INTELIGENCIA (COGNITIVA)',
      6: 'APLICACIÓN DE PRUEBAS NEUROPSICOLOGICAS',
      7: 'VALORACIÓN NEUROPSICOLÓGICA PRESENCIAL',
      8: 'REHABILITACIÓN NEUROPSICOLÓGICA',
      9: 'FISIATRIA INICIAL/PRESENCIAL',
      11: 'HIDROTERAPIA',
      12: 'JUNTA MEDICA',
      14: 'WEB_HIDROTERAPIA (TERAPIAS HIDRICAS O HIDRAULICAS)',
      17: 'EVALUACIÓN POR EQUIPO INTERDISCIPLINARIO',
      18: 'FISIATRIA FINAL/VIRTUAL',
      19: 'INGRESO A PROGRAMA DE REHABILITACION ADMINISTRATIVO',
      20: 'PROGRAMA DE REHABILITACION',
      21: 'SESION ABIERTA FONOAUDIOLOGIA',
      22: 'SESION ABIERTA FISIOTERAPIA',
      23: 'SESION ABIERTA PSICOLOGIA',
      24: 'SESION ABIERTA TERAPIA OCUPACIONAL',
      25: 'PSICOLOGIA PROGRAMA',
      26: 'FISIOTERAPIA FINAL',
      27: 'FONOAUDIOLOGIA PROGRAMA',
      28: 'TERAPIA OCUPACIONAL (NEURODESARROLLO)',
      31: 'TERAPIA COGNITIVA CONDUCTUAL',
      32: 'PSICOTERAPIA FAMILIAR',
      33: 'PSICOTERAPIA GRUPAL',
      34: 'PSICOTERAPIA INDIVIDUAL',
      35: 'NATACION',
      36: 'FISIOTERAPIA INICIAL/VIRTUAL',
      38: 'FISIOTERAPIA PROGRAMA',
      39: 'PSIQUIATRIA PEDIATRICA PROGRAMA/VIRTUAL',
      40: 'PSIQUIATRIA EVENTO/VIRTUAL',
      41: 'NEUROLOGIA PEDIATRICA EVENTO TELEXPERTICIA',
      42: 'FISIATRIA REHABILITACION/PRESENCIAL',
      45: 'PSIQUIATRÍA PEDIATRICA EVENTO PRESENCIAL',
      47: 'FISIATRIA REHABILITACION/VIRTUAL',
      48: 'VALORACIÓN NEUROPSICOLÓGICA VIRTUAL',
      49: 'NEUROLOGIA PEDIATRICA EVENTO/VIRTUAL',
      52: 'FISIOTERAPIA INICIAL/PRESENCIAL',
      53: 'TERAPIA OCUPACIONAL PROGRAMA',
      54: 'ANALISIS DE CASOS',
      55: 'VALORACION DE INGRESO A PROGRAMA DE REHABILITACIÓN-PSIQUIATRIA-VIRTUAL',
      56: 'VALORACION DE INGRESO A PROGRAMA DE REHABILITACIÓN-FISIATRIA-VIRTUAL',
      57: 'VALORACION DE INGRESO A PROGRAMA DE REHABILITACION-GRUPO TERAPEUTICO',
      58: 'VALORACION DE INGRESO A PROGRAMA DE REHABILITACIÓN-FISIATRIA-PRESENCIAL',
      59: 'VALORACION DE INGRESO A PROGRAMA PSIQUIATRIA PRESENCIAL',
      60: 'WEB_FISIOTERAPIA INICIAL/VIRTUAL',
      61: 'WEB_FISIOTERAPIA FINAL',
      62: 'WEB_NATACION',
      63: 'Gestión Administrativa',
      64: 'PSIQUIATRÍA PEDIATRICA PROGRAMA TELEXPERTICIA',
      65: 'PSIQUIATRÍA PEDIATRICA EVENTO TELEXPERTICIA',
      66: 'FISIATRIA TELEXPERTICIA (HDT)',
      67: 'ACTIVIDADES BASICAS COTIDIANAS',
      68: 'PSIQUIATRIA PEDIATRICA EVENTO TELEXPERTICIA',
      69: 'PSIQUIATRIA PEDIATRICA PROGRAMA TELEXPERTICIA',
      70: 'FISIATRIA TELEXPERTICIA (RHB)',
      71: 'FISIOTERAPIA INICIAL/VIRTUAL COMPENSAR',
      73: 'NATACIÓN WEB NUEVA ENTIDAD',
      74: 'INTERVENCIÓN MÉDICO TERAPÉUTICA',
      75: 'YOGA',
      76: 'PILATES',
      85: 'MATRONATACIÓN GRUPAL NIVEL 2 (10 A 15 MESES)',
      86: 'MATRONATACIÓN GRUPAL NIVEL 3 (16 A 36 MESES)',
      87: 'HABILIDADES BÁSICAS GRUPAL (3 A 13 AÑOS)',
      88: 'FUNDAMENTACIÓN 1 GRUPAL (3 A 13 AÑOS)',
      89: 'FUNDAMENTACIÓN 2 GRUPAL (3 A 13 AÑOS)',
      90: 'TÉCNICAS DEPORTIVAS 1 (3 A 13 AÑOS)',
      91: 'TÉCNICAS DEPORTIVAS 2 (3 A 13 AÑOS)',
      92: 'TÉCNICAS DEPORTIVAS 3 (3 A 13 AÑOS)',
      93: 'TÉCNICAS DEPORTIVAS 4 (3 A 13 AÑOS)',
      94: 'NATACIÓN PERSONALIZADA',
    };

    final int? idServicio = int.tryParse(tipo.toString());

    if (idServicio == null) {
      return '';
    }

    return arrayServicios[idServicio] ?? '';
  }

  static void limpiarSesion() {
    idPaciente = '';
    tipoDocumento = '';
    documentoIdentidad = '';
    nombrePaciente = '';
    correoElectronico = '';
    celular = null;
    perfil = null;
    eps = '';
    ciudad = null;
    sede = '';

    autorizacionId = null;
    numeroAutorizacion = null;
    fechaInicio = null;
    fechaFinal = null;
    fechaInicior = null;
    fechaFinalr = null;
    paquete = null;

    codeContract = null;
    codePlan = null;
    codeRegimen = null;
    codeTypeAffiliate = null;
    codeLevelAffiliate = null;

    examen = '';
    cantidad = null;
    sede_agenda = null;


  }
  
}

