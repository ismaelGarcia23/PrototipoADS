-- Database: bosko-hostal-v1

-- DROP DATABASE IF EXISTS "bosko-hostal-v1";

CREATE DATABASE "bosko-hostal-v1"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'es-ES'
    LC_CTYPE = 'es-ES'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

-- 1. Habilitar extensión para UUID
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Seguridad y permisos

CREATE TABLE usuario (
  usuario_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre      VARCHAR(100) NOT NULL,
  pin         VARCHAR(10)  NOT NULL UNIQUE,
  activo      BOOLEAN      NOT NULL DEFAULT TRUE,
  creado_en   TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE rol (
  rol_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE permiso (
  permiso_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre      VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE rol_permiso (
  rol_id     UUID NOT NULL,
  permiso_id UUID NOT NULL,
  PRIMARY KEY (rol_id, permiso_id),
  FOREIGN KEY (rol_id)     REFERENCES rol(rol_id),
  FOREIGN KEY (permiso_id) REFERENCES permiso(permiso_id)
);

CREATE TABLE usuario_rol (
  usuario_id UUID NOT NULL,
  rol_id     UUID NOT NULL,
  PRIMARY KEY (usuario_id, rol_id),
  FOREIGN KEY (usuario_id) REFERENCES usuario(usuario_id),
  FOREIGN KEY (rol_id)     REFERENCES rol(rol_id)
);

-- 3. Perfil de usuario (datos personales + avatar)

CREATE TABLE perfil_usuario (
  usuario_id   UUID PRIMARY KEY REFERENCES usuario(usuario_id),
  email        VARCHAR(100),
  telefono     VARCHAR(50),
  direccion    TEXT,
  documento    VARCHAR(50),    -- DUI, NIT, etc.
  avatar_url   VARCHAR(200),   -- URL de la foto de perfil 
  avatar_subida TIMESTAMP      -- fecha de última actualización de avatar
);

-- 4. Catálogos básicos

CREATE TABLE categoria_producto (
  categoria_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre        VARCHAR(100) NOT NULL,
  descripcion   TEXT
);

CREATE TABLE marca (
  marca_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre     VARCHAR(100) NOT NULL,
  descripcion TEXT
);

CREATE TABLE proveedor (
  proveedor_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre        VARCHAR(100) NOT NULL,
  contacto      VARCHAR(100),
  telefono      VARCHAR(50),
  email         VARCHAR(100),
  direccion     TEXT
);

-- 5. Productos, platos y recetas

CREATE TABLE producto (
  producto_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre        VARCHAR(100) NOT NULL,
  descripcion   TEXT,
  precio        DECIMAL(10,2) NOT NULL,
  stock_actual  INT NOT NULL DEFAULT 0,
  categoria_id  UUID REFERENCES categoria_producto(categoria_id)
);

CREATE TABLE producto_marca (
  producto_id UUID NOT NULL REFERENCES producto(producto_id),
  marca_id    UUID NOT NULL REFERENCES marca(marca_id),
  PRIMARY KEY (producto_id, marca_id)
);

CREATE TABLE plato (
  plato_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre       VARCHAR(100) NOT NULL,
  descripcion  TEXT,
  precio       DECIMAL(10,2) NOT NULL,
  categoria_id UUID REFERENCES categoria_producto(categoria_id)
);

CREATE TABLE receta_item (
  receta_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plato_id       UUID NOT NULL REFERENCES plato(plato_id),
  producto_id    UUID NOT NULL REFERENCES producto(producto_id),
  cantidad       INT NOT NULL
);

-- 6. Áreas y mesas

CREATE TABLE area_servicio (
  area_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE mesa (
  mesa_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  numero     INT NOT NULL,
  capacidad  INT NOT NULL,
  area_id    UUID NOT NULL REFERENCES area_servicio(area_id),
  estado     VARCHAR(20) NOT NULL DEFAULT 'LIBRE'
);

-- 7. Estados estáticos

CREATE TABLE estado_comanda (
  estado_comanda_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre            VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE estado_ticket (
  estado_ticket_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre           VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE estado_reserva (
  estado_reserva_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre            VARCHAR(50) NOT NULL UNIQUE
);

-- 8. Promociones

CREATE TABLE promocion (
  promocion_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre        VARCHAR(100) NOT NULL,
  descripcion   TEXT,
  fecha_inicio  DATE,
  fecha_fin     DATE
);

CREATE TABLE promocion_item (
  promocion_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  promocion_id      UUID NOT NULL REFERENCES promocion(promocion_id),
  producto_id       UUID REFERENCES producto(producto_id),
  plato_id          UUID REFERENCES plato(plato_id)
);

-- 9. Comandas y tickets

CREATE TABLE comanda (
  comanda_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fecha_hora        TIMESTAMP NOT NULL DEFAULT NOW(),
  mesa_id           UUID NOT NULL REFERENCES mesa(mesa_id),
  mesero_id         UUID NOT NULL REFERENCES usuario(usuario_id),
  area_id           UUID NOT NULL REFERENCES area_servicio(area_id),
  estado_comanda_id UUID NOT NULL REFERENCES estado_comanda(estado_comanda_id),
  total             DECIMAL(10,2) NOT NULL DEFAULT 0
);

CREATE TABLE comanda_item (
  comanda_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  comanda_id      UUID NOT NULL REFERENCES comanda(comanda_id),
  producto_id     UUID REFERENCES producto(producto_id),
  plato_id        UUID REFERENCES plato(plato_id),
  cantidad        INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL
);

CREATE TABLE ticket (
  ticket_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fecha_hora           TIMESTAMP NOT NULL DEFAULT NOW(),
  comanda_id           UUID NOT NULL REFERENCES comanda(comanda_id),
  cajero_id            UUID NOT NULL REFERENCES usuario(usuario_id),
  cliente_usuario_id   UUID NULL REFERENCES usuario(usuario_id),
  estado_ticket_id     UUID NOT NULL REFERENCES estado_ticket(estado_ticket_id),
  total                DECIMAL(10,2) NOT NULL,
  anulado              BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE ticket_item (
  ticket_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id      UUID NOT NULL REFERENCES ticket(ticket_id),
  producto_id    UUID REFERENCES producto(producto_id),
  plato_id       UUID REFERENCES plato(plato_id),
  cantidad       INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL
);

-- 10. Compras e inventario

CREATE TABLE compra (
  compra_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fecha_hora   TIMESTAMP NOT NULL DEFAULT NOW(),
  proveedor_id UUID NOT NULL REFERENCES proveedor(proveedor_id),
  usuario_id   UUID NOT NULL REFERENCES usuario(usuario_id),
  total        DECIMAL(10,2) NOT NULL
);

CREATE TABLE compra_item (
  compra_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  compra_id      UUID NOT NULL REFERENCES compra(compra_id),
  producto_id    UUID NOT NULL REFERENCES producto(producto_id),
  cantidad       INT NOT NULL,
  costo_unitario DECIMAL(10,2) NOT NULL
);

CREATE TABLE stock_movimiento (
  stock_movimiento_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producto_id         UUID NOT NULL REFERENCES producto(producto_id),
  fecha_hora          TIMESTAMP NOT NULL DEFAULT NOW(),
  tipo                VARCHAR(20) NOT NULL CHECK (tipo IN ('INGRESO','SALIDA')),
  cantidad            INT NOT NULL,
  referencia          VARCHAR(100),
  usuario_id          UUID NOT NULL REFERENCES usuario(usuario_id)
);

-- 11. Caja y finanzas

CREATE TABLE caja_turno (
  caja_turno_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fecha_apertura TIMESTAMP NOT NULL DEFAULT NOW(),
  fecha_cierre   TIMESTAMP,
  usuario_id     UUID NOT NULL REFERENCES usuario(usuario_id),
  monto_inicial  DECIMAL(10,2) NOT NULL,
  monto_final    DECIMAL(10,2)
);

CREATE TABLE caja_movimiento (
  caja_movimiento_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caja_turno_id      UUID NOT NULL REFERENCES caja_turno(caja_turno_id),
  tipo_movimiento    VARCHAR(10) NOT NULL CHECK (tipo_movimiento IN ('INGRESO','EGRESO')),
  monto              DECIMAL(10,2) NOT NULL,
  descripcion        TEXT
);

-- 12. Reservas (clientes como usuarios)

CREATE TABLE reserva (
  reserva_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id        UUID NOT NULL REFERENCES usuario(usuario_id),
  mesa_id           UUID NOT NULL REFERENCES mesa(mesa_id),
  fecha_hora        TIMESTAMP NOT NULL,
  personas          INT NOT NULL,
  estado_reserva_id UUID NOT NULL REFERENCES estado_reserva(estado_reserva_id)
);

-- 13. Pagos

CREATE TABLE metodo_pago (
  metodo_pago_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre          VARCHAR(50) NOT NULL UNIQUE,
  detalle         TEXT
);

CREATE TABLE pago (
  pago_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id       UUID REFERENCES ticket(ticket_id),
  reserva_id      UUID REFERENCES reserva(reserva_id),
  metodo_pago_id  UUID NOT NULL REFERENCES metodo_pago(metodo_pago_id),
  monto           DECIMAL(10,2) NOT NULL,
  fecha_hora      TIMESTAMP NOT NULL DEFAULT NOW(),
  referencia      VARCHAR(100)
);

-- 14. Configuraciones y personalización

CREATE TABLE config_impresora (
  impresora_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre        VARCHAR(100) NOT NULL,
  comando_escpos TEXT NOT NULL
);

CREATE TABLE config_ticket (
  config_ticket_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campo             VARCHAR(100) NOT NULL,
  valor             VARCHAR(200) NOT NULL
);

CREATE TABLE config_general (
  config_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  propina_activa      BOOLEAN NOT NULL DEFAULT FALSE,
  seleccion_multiple  BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE empresa_config (
  empresa_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre         VARCHAR(200) NOT NULL,
  nit            VARCHAR(50),
  direccion      TEXT,
  telefono       VARCHAR(50),
  email          VARCHAR(100),
  logo_ruta      VARCHAR(200),
  datos_fiscales TEXT
);

-- 15. Auditoría

CREATE TABLE audit_log (
  log_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES usuario(usuario_id),
  accion     VARCHAR(200) NOT NULL,
  fecha_hora TIMESTAMP NOT NULL DEFAULT NOW(),
  detalle    TEXT
);

-- 16. Imágenes por entidad

CREATE TABLE imagen_producto (
  imagen_producto_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producto_id        UUID NOT NULL REFERENCES producto(producto_id),
  ruta_url           VARCHAR(200) NOT NULL,
  descripcion        TEXT,
  fecha_subida       TIMESTAMP NOT NULL DEFAULT NOW(),
  orden              INT NOT NULL DEFAULT 1
);

CREATE TABLE imagen_plato (
  imagen_plato_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plato_id        UUID NOT NULL REFERENCES plato(plato_id),
  ruta_url        VARCHAR(200) NOT NULL,
  descripcion     TEXT,
  fecha_subida    TIMESTAMP NOT NULL DEFAULT NOW(),
  orden           INT NOT NULL DEFAULT 1
);

CREATE TABLE imagen_usuario (
  imagen_usuario_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id        UUID NOT NULL REFERENCES usuario(usuario_id),
  ruta_url          VARCHAR(200) NOT NULL,
  descripcion       TEXT,
  fecha_subida      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE imagen_area_servicio (
  imagen_area_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  area_id        UUID NOT NULL REFERENCES area_servicio(area_id),
  ruta_url       VARCHAR(200) NOT NULL,
  descripcion    TEXT,
  fecha_subida   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE imagen_empresa (
  imagen_empresa_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id        UUID NOT NULL REFERENCES empresa_config(empresa_id),
  ruta_url          VARCHAR(200) NOT NULL,
  descripcion       TEXT,
  fecha_subida      TIMESTAMP NOT NULL DEFAULT NOW()
);

