-- =========================================================
-- BASE DE DATOS GIMNASIO
-- Susana Nuñez, Bruno Herraez y Marcos Gil
-- =========================================================

DROP DATABASE IF EXISTS gimnasio_bd;
CREATE DATABASE gimnasio_bd CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gimnasio_bd;

-- =========================================================
-- TABLA: usuario
-- =========================================================
CREATE TABLE usuario (
    dni CHAR(9) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    fecha_alta DATE NOT NULL,
    estado ENUM('activo', 'inactivo', 'baja') NOT NULL,
    CONSTRAINT chk_usuario_dni CHECK (CHAR_LENGTH(dni) = 9)
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: administrador
-- =========================================================
CREATE TABLE administrador (
    dni_usuario CHAR(9) PRIMARY KEY,
    CONSTRAINT fk_administrador_usuario
        FOREIGN KEY (dni_usuario)
        REFERENCES usuario(dni)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: recepcionista
-- =========================================================
CREATE TABLE recepcionista (
    dni_usuario CHAR(9) PRIMARY KEY,
    CONSTRAINT fk_recepcionista_usuario
        FOREIGN KEY (dni_usuario)
        REFERENCES usuario(dni)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: entrenador
-- =========================================================
CREATE TABLE entrenador (
    dni_usuario CHAR(9) PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    CONSTRAINT fk_entrenador_usuario
        FOREIGN KEY (dni_usuario)
        REFERENCES usuario(dni)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: socio
-- =========================================================
CREATE TABLE socio (
    dni_usuario CHAR(9) PRIMARY KEY,
    tipo_plan ENUM('full', 'flexible') NOT NULL,
    estado ENUM('activo', 'moroso', 'baja') NOT NULL,
    CONSTRAINT fk_socio_usuario
        FOREIGN KEY (dni_usuario)
        REFERENCES usuario(dni)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: full
-- =========================================================
CREATE TABLE full (
    dni_socio CHAR(9) PRIMARY KEY,
    cuota_mensual DECIMAL(8,2) NOT NULL,
    CONSTRAINT fk_full_socio
        FOREIGN KEY (dni_socio)
        REFERENCES socio(dni_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_full_cuota CHECK (cuota_mensual > 0)
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: flexible
-- =========================================================
CREATE TABLE flexible (
    dni_socio CHAR(9) PRIMARY KEY,
    precio_por_actividad DECIMAL(8,2) NOT NULL,
    CONSTRAINT fk_flexible_socio
        FOREIGN KEY (dni_socio)
        REFERENCES socio(dni_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_flexible_precio CHECK (precio_por_actividad > 0)
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: nomina
-- =========================================================
CREATE TABLE nomina (
    id_nomina INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    salario_base DECIMAL(10,2) NOT NULL,
    salario_neto DECIMAL(10,2) NOT NULL,
    dni_usuario CHAR(9) NOT NULL,
    CONSTRAINT fk_nomina_usuario
        FOREIGN KEY (dni_usuario)
        REFERENCES usuario(dni)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_nomina_salarios CHECK (salario_base > 0 AND salario_neto > 0 AND salario_neto <= salario_base)
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: actividad
-- =========================================================
CREATE TABLE actividad (
    id_actividad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    nivel ENUM('bajo', 'medio', 'alto') NOT NULL
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: sala
-- =========================================================
CREATE TABLE sala (
    id_sala INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    m_cuadrados DECIMAL(8,2) NOT NULL,
    aforo_max INT NOT NULL,
    CONSTRAINT chk_sala_m2 CHECK (m_cuadrados > 0),
    CONSTRAINT chk_sala_aforo CHECK (aforo_max > 0)
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: actividad_programada
-- =========================================================
CREATE TABLE actividad_programada (
    id_actividad INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,
    dni_entrenador CHAR(9) NOT NULL,
    id_sala INT NOT NULL,
    PRIMARY KEY (id_actividad, fecha_inicio),
    CONSTRAINT fk_actividad_programada_actividad
        FOREIGN KEY (id_actividad)
        REFERENCES actividad(id_actividad)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_actividad_programada_entrenador
        FOREIGN KEY (dni_entrenador)
        REFERENCES entrenador(dni_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_actividad_programada_sala
        FOREIGN KEY (id_sala)
        REFERENCES sala(id_sala)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_actividad_programada_fechas CHECK (fecha_fin > fecha_inicio)
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: maquinaria
-- =========================================================
CREATE TABLE maquinaria (
    id_maquinaria INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(80) NOT NULL,
    marca VARCHAR(80) NOT NULL,
    n_serie VARCHAR(100) NOT NULL UNIQUE,
    estado ENUM('operativa', 'mantenimiento', 'averiada') NOT NULL,
    fecha_compra DATE NOT NULL,
    fecha_ultimo_mantenimiento DATE NOT NULL,
    CONSTRAINT chk_maquinaria_fechas CHECK (fecha_ultimo_mantenimiento >= fecha_compra)
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: pago
-- =========================================================
CREATE TABLE pago (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    fecha_pago DATE NOT NULL,
    tipo_pago ENUM('tarjeta', 'efectivo', 'transferencia', 'bizum') NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_pago_cantidad CHECK (cantidad > 0)
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: pago_mensual
-- =========================================================
CREATE TABLE pago_mensual (
    id_pago INT PRIMARY KEY,
    dni_socio_full CHAR(9) NOT NULL,
    CONSTRAINT fk_pago_mensual_pago
        FOREIGN KEY (id_pago)
        REFERENCES pago(id_pago)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_pago_mensual_full
        FOREIGN KEY (dni_socio_full)
        REFERENCES full(dni_socio)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: pago_actividad
-- =========================================================
CREATE TABLE pago_actividad (
    id_pago INT PRIMARY KEY,
    dni_socio_flexible CHAR(9) NOT NULL,
    id_actividad INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    CONSTRAINT fk_pago_actividad_pago
        FOREIGN KEY (id_pago)
        REFERENCES pago(id_pago)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_pago_actividad_flexible
        FOREIGN KEY (dni_socio_flexible)
        REFERENCES flexible(dni_socio)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_pago_actividad_programada
        FOREIGN KEY (id_actividad, fecha_inicio)
        REFERENCES actividad_programada(id_actividad, fecha_inicio)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: poder_impartir
-- =========================================================
CREATE TABLE poder_impartir (
    dni_entrenador CHAR(9) NOT NULL,
    id_actividad INT NOT NULL,
    PRIMARY KEY (dni_entrenador, id_actividad),
    CONSTRAINT fk_poder_impartir_entrenador
        FOREIGN KEY (dni_entrenador)
        REFERENCES entrenador(dni_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_poder_impartir_actividad
        FOREIGN KEY (id_actividad)
        REFERENCES actividad(id_actividad)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: permitir
-- =========================================================
CREATE TABLE permitir (
    id_actividad INT NOT NULL,
    id_sala INT NOT NULL,
    PRIMARY KEY (id_actividad, id_sala),
    CONSTRAINT fk_permitir_actividad
        FOREIGN KEY (id_actividad)
        REFERENCES actividad(id_actividad)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_permitir_sala
        FOREIGN KEY (id_sala)
        REFERENCES sala(id_sala)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: ser_disponible
-- =========================================================
CREATE TABLE ser_disponible (
    id_sala INT NOT NULL,
    id_maquinaria INT NOT NULL,
    PRIMARY KEY (id_sala, id_maquinaria),
    CONSTRAINT fk_ser_disponible_sala
        FOREIGN KEY (id_sala)
        REFERENCES sala(id_sala)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_ser_disponible_maquinaria
        FOREIGN KEY (id_maquinaria)
        REFERENCES maquinaria(id_maquinaria)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: reserva
-- =========================================================
CREATE TABLE reserva (
    dni_socio CHAR(9) NOT NULL,
    id_actividad INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    PRIMARY KEY (dni_socio, id_actividad, fecha_inicio),
    CONSTRAINT fk_reserva_socio
        FOREIGN KEY (dni_socio)
        REFERENCES socio(dni_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_reserva_actividad_programada
        FOREIGN KEY (id_actividad, fecha_inicio)
        REFERENCES actividad_programada(id_actividad, fecha_inicio)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLA: corresponder
-- =========================================================
CREATE TABLE corresponder (
    id_pago INT NOT NULL,
    id_actividad INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    PRIMARY KEY (id_pago, id_actividad, fecha_inicio),
    CONSTRAINT fk_corresponder_pago_actividad
        FOREIGN KEY (id_pago)
        REFERENCES pago_actividad(id_pago)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_corresponder_actividad_programada
        FOREIGN KEY (id_actividad, fecha_inicio)
        REFERENCES actividad_programada(id_actividad, fecha_inicio)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- ÍNDICES
-- =========================================================
CREATE INDEX idx_usuario_apellidos ON usuario(apellidos);
CREATE INDEX idx_usuario_estado ON usuario(estado);

CREATE INDEX idx_socio_tipo_plan ON socio(tipo_plan);
CREATE INDEX idx_socio_estado ON socio(estado);

CREATE INDEX idx_nomina_fecha ON nomina(fecha);
CREATE INDEX idx_nomina_dni_usuario ON nomina(dni_usuario);

CREATE INDEX idx_actividad_nombre ON actividad(nombre);
CREATE INDEX idx_sala_nombre ON sala(nombre);

CREATE INDEX idx_actividad_programada_entrenador ON actividad_programada(dni_entrenador);
CREATE INDEX idx_actividad_programada_sala ON actividad_programada(id_sala);
CREATE INDEX idx_actividad_programada_fecha_fin ON actividad_programada(fecha_fin);

CREATE INDEX idx_maquinaria_tipo ON maquinaria(tipo);
CREATE INDEX idx_maquinaria_estado ON maquinaria(estado);

CREATE INDEX idx_pago_fecha ON pago(fecha_pago);
CREATE INDEX idx_pago_tipo ON pago(tipo_pago);

CREATE INDEX idx_pago_mensual_socio ON pago_mensual(dni_socio_full);

CREATE INDEX idx_pago_actividad_socio ON pago_actividad(dni_socio_flexible);
CREATE INDEX idx_pago_actividad_actividad_fecha ON pago_actividad(id_actividad, fecha_inicio);

CREATE INDEX idx_reserva_socio ON reserva(dni_socio);
CREATE INDEX idx_reserva_actividad_fecha ON reserva(id_actividad, fecha_inicio);

-- =========================================================
-- DATOS DE PRUEBA
-- =========================================================

-- USUARIOS
INSERT INTO usuario (dni, nombre, apellidos, telefono, email, fecha_alta, estado) VALUES
('11111111A', 'Carlos', 'Lopez Martin', '600111111', 'carlos.lopez@gym.com', '2025-01-10', 'activo'),
('22222222B', 'Laura', 'Sanchez Ruiz', '600222222', 'laura.sanchez@gym.com', '2025-01-12', 'activo'),
('33333333C', 'Mario', 'Perez Gil', '600333333', 'mario.perez@gym.com', '2025-01-15', 'activo'),
('44444444D', 'Ana', 'Torres Diaz', '600444444', 'ana.torres@gym.com', '2025-01-20', 'activo'),
('55555555E', 'David', 'Navarro Sanz', '600555555', 'david.navarro@gym.com', '2025-02-01', 'activo'),
('66666666F', 'Lucia', 'Romero Vidal', '600666666', 'lucia.romero@gym.com', '2025-02-05', 'activo'),
('77777777G', 'Sergio', 'Moreno Casas', '600777777', 'sergio.moreno@gym.com', '2025-02-08', 'activo'),
('88888888H', 'Paula', 'Herrera Leon', '600888888', 'paula.herrera@gym.com', '2025-02-10', 'activo'),
('99999999I', 'Javier', 'Ruiz Ortega', '600999999', 'javier.ruiz@gym.com', '2025-02-12', 'activo'),
('10101010J', 'Marta', 'Cano Prieto', '601010101', 'marta.cano@gym.com', '2025-02-15', 'activo'),
('12121212K', 'Alberto', 'Mendez Pardo', '601212121', 'alberto.mendez@gym.com', '2025-02-18', 'activo'),
('13131313L', 'Claudia', 'Iglesias Mora', '601313131', 'claudia.iglesias@gym.com', '2025-02-20', 'activo'),
('14141414M', 'Ruben', 'Soto Vega', '601414141', 'ruben.soto@gym.com', '2025-02-22', 'activo'),
('15151515N', 'Elena', 'Calvo Nieto', '601515151', 'elena.calvo@gym.com', '2025-02-25', 'activo'),
('16161616P', 'Hugo', 'Blanco Serra', '601616161', 'hugo.blanco@gym.com', '2025-03-01', 'activo');

-- ADMINISTRADORES
INSERT INTO administrador (dni_usuario) VALUES
('11111111A'),
('22222222B');

-- RECEPCIONISTAS
INSERT INTO recepcionista (dni_usuario) VALUES
('33333333C'),
('44444444D');

-- ENTRENADORES
INSERT INTO entrenador (dni_usuario, tipo) VALUES
('55555555E', 'musculacion'),
('66666666F', 'crossfit'),
('77777777G', 'yoga'),
('88888888H', 'spinning');

-- SOCIOS
INSERT INTO socio (dni_usuario, tipo_plan, estado) VALUES
('99999999I', 'full', 'activo'),
('10101010J', 'full', 'activo'),
('12121212K', 'full', 'moroso'),
('13131313L', 'flexible', 'activo'),
('14141414M', 'flexible', 'activo'),
('15151515N', 'flexible', 'baja'),
('16161616P', 'full', 'activo');

-- FULL
INSERT INTO full (dni_socio, cuota_mensual) VALUES
('99999999I', 45.00),
('10101010J', 45.00),
('12121212K', 45.00),
('16161616P', 50.00);

-- FLEXIBLE
INSERT INTO flexible (dni_socio, precio_por_actividad) VALUES
('13131313L', 8.00),
('14141414M', 8.00),
('15151515N', 10.00);

-- NÓMINAS
INSERT INTO nomina (fecha, salario_base, salario_neto, dni_usuario) VALUES
('2026-01-31', 1800.00, 1550.00, '11111111A'),
('2026-02-28', 1800.00, 1550.00, '11111111A'),
('2026-01-31', 1750.00, 1500.00, '22222222B'),
('2026-02-28', 1750.00, 1500.00, '22222222B'),
('2026-01-31', 1400.00, 1250.00, '33333333C'),
('2026-02-28', 1400.00, 1250.00, '33333333C'),
('2026-01-31', 1400.00, 1250.00, '44444444D'),
('2026-02-28', 1400.00, 1250.00, '44444444D'),
('2026-02-28', 1600.00, 1380.00, '55555555E'),
('2026-02-28', 1600.00, 1380.00, '66666666F');

-- ACTIVIDADES
INSERT INTO actividad (nombre, descripcion, nivel) VALUES
('Yoga', 'Sesion de yoga para flexibilidad y relajacion', 'bajo'),
('Spinning', 'Clase de bicicleta estatica de alta intensidad', 'alto'),
('Pilates', 'Trabajo de core, postura y control corporal', 'medio'),
('Crossfit', 'Entrenamiento funcional de alta intensidad', 'alto'),
('Zumba', 'Baile fitness con coreografias dinamicas', 'medio'),
('Body Pump', 'Entrenamiento con pesas y barra', 'alto'),
('HIIT', 'Entrenamiento por intervalos de alta intensidad', 'alto'),
('Estiramientos', 'Sesion guiada para movilidad y recuperacion', 'bajo'),
('Entrenamiento Funcional', 'Circuito de fuerza y resistencia', 'medio'),
('Gap', 'Gluteos, abdominales y piernas', 'medio');

-- SALAS
INSERT INTO sala (nombre, m_cuadrados, aforo_max) VALUES
('Sala 1', 80.00, 25),
('Sala 2', 60.00, 20),
('Sala 3', 100.00, 30),
('Sala Spinning', 90.00, 24),
('Sala Funcional', 120.00, 35),
('Sala Relax', 50.00, 15);

-- ACTIVIDADES PROGRAMADAS
INSERT INTO actividad_programada (id_actividad, fecha_inicio, fecha_fin, dni_entrenador, id_sala) VALUES
(1, '2026-04-20 09:00:00', '2026-04-20 10:00:00', '77777777G', 6),
(2, '2026-04-20 18:00:00', '2026-04-20 19:00:00', '88888888H', 4),
(3, '2026-04-21 10:00:00', '2026-04-21 11:00:00', '77777777G', 2),
(4, '2026-04-21 19:00:00', '2026-04-21 20:00:00', '66666666F', 5),
(5, '2026-04-22 17:00:00', '2026-04-22 18:00:00', '88888888H', 3),
(6, '2026-04-22 19:00:00', '2026-04-22 20:00:00', '55555555E', 5),
(7, '2026-04-23 18:30:00', '2026-04-23 19:30:00', '66666666F', 5),
(8, '2026-04-23 09:00:00', '2026-04-23 10:00:00', '77777777G', 6),
(9, '2026-04-24 18:00:00', '2026-04-24 19:00:00', '55555555E', 5),
(10, '2026-04-24 19:15:00', '2026-04-24 20:00:00', '55555555E', 2),
(1, '2026-04-25 11:00:00', '2026-04-25 12:00:00', '77777777G', 6),
(2, '2026-04-25 17:00:00', '2026-04-25 18:00:00', '88888888H', 4);

-- MAQUINARIA
INSERT INTO maquinaria (tipo, marca, n_serie, estado, fecha_compra, fecha_ultimo_mantenimiento) VALUES
('Cinta de correr', 'Technogym', 'TG-CINTA-001', 'operativa', '2024-01-10', '2026-03-01'),
('Bicicleta estatica', 'BH', 'BH-BICI-001', 'operativa', '2024-02-15', '2026-03-10'),
('Eliptica', 'Life Fitness', 'LF-ELIP-001', 'operativa', '2024-03-20', '2026-03-05'),
('Banco press', 'Matrix', 'MX-BANCO-001', 'operativa', '2024-01-25', '2026-02-28'),
('Jaula multipower', 'Bodytone', 'BT-JAULA-001', 'operativa', '2024-04-10', '2026-03-02'),
('Remo', 'Concept2', 'C2-REMO-001', 'mantenimiento', '2024-05-05', '2026-04-01'),
('Bicicleta spinning', 'Keiser', 'KS-SPIN-001', 'operativa', '2024-06-12', '2026-03-15'),
('Juego mancuernas', 'Domyos', 'DM-MANC-001', 'operativa', '2024-07-01', '2026-02-20'),
('Polea alta', 'Technogym', 'TG-POLEA-001', 'averiada', '2024-08-08', '2026-03-25'),
('Step profesional', 'Reebok', 'RB-STEP-001', 'operativa', '2024-09-14', '2026-03-18');

-- PUEDE IMPARTIR
INSERT INTO poder_impartir (dni_entrenador, id_actividad) VALUES
('77777777G', 1),
('77777777G', 3),
('77777777G', 8),
('88888888H', 2),
('88888888H', 5),
('88888888H', 10),
('66666666F', 4),
('66666666F', 7),
('55555555E', 6),
('55555555E', 9),
('55555555E', 10),
('66666666F', 9);

-- PERMITIR
INSERT INTO permitir (id_actividad, id_sala) VALUES
(1, 6),
(2, 4),
(3, 2),
(4, 5),
(5, 3),
(6, 5),
(7, 5),
(8, 6),
(9, 5),
(10, 2),
(1, 2),
(5, 1);

-- SER DISPONIBLE
INSERT INTO ser_disponible (id_sala, id_maquinaria) VALUES
(4, 7),
(4, 2),
(5, 5),
(5, 6),
(5, 8),
(5, 9),
(1, 1),
(1, 3),
(2, 4),
(2, 10),
(3, 8),
(3, 4);

-- PAGOS
INSERT INTO pago (fecha_pago, tipo_pago, cantidad) VALUES
('2026-04-01', 'tarjeta', 45.00),
('2026-04-01', 'transferencia', 45.00),
('2026-04-01', 'bizum', 45.00),
('2026-04-01', 'tarjeta', 50.00),
('2026-04-20', 'efectivo', 8.00),
('2026-04-21', 'tarjeta', 8.00),
('2026-04-22', 'bizum', 8.00),
('2026-04-23', 'transferencia', 8.00),
('2026-04-24', 'efectivo', 10.00),
('2026-04-25', 'tarjeta', 8.00);

-- PAGOS MENSUALES
INSERT INTO pago_mensual (id_pago, dni_socio_full) VALUES
(1, '99999999I'),
(2, '10101010J'),
(3, '12121212K'),
(4, '16161616P');

-- PAGOS POR ACTIVIDAD
INSERT INTO pago_actividad (id_pago, dni_socio_flexible, id_actividad, fecha_inicio) VALUES
(5, '13131313L', 1, '2026-04-20 09:00:00'),
(6, '14141414M', 3, '2026-04-21 10:00:00'),
(7, '13131313L', 5, '2026-04-22 17:00:00'),
(8, '14141414M', 8, '2026-04-23 09:00:00'),
(9, '15151515N', 10, '2026-04-24 19:15:00'),
(10, '13131313L', 1, '2026-04-25 11:00:00');

-- CORRESPONDER
INSERT INTO corresponder (id_pago, id_actividad, fecha_inicio) VALUES
(5, 1, '2026-04-20 09:00:00'),
(6, 3, '2026-04-21 10:00:00'),
(7, 5, '2026-04-22 17:00:00'),
(8, 8, '2026-04-23 09:00:00'),
(9, 10, '2026-04-24 19:15:00'),
(10, 1, '2026-04-25 11:00:00');

-- RESERVAS
INSERT INTO reserva (dni_socio, id_actividad, fecha_inicio) VALUES
('99999999I', 2, '2026-04-20 18:00:00'),
('10101010J', 4, '2026-04-21 19:00:00'),
('12121212K', 6, '2026-04-22 19:00:00'),
('13131313L', 1, '2026-04-20 09:00:00'),
('14141414M', 3, '2026-04-21 10:00:00'),
('13131313L', 5, '2026-04-22 17:00:00'),
('14141414M', 8, '2026-04-23 09:00:00'),
('15151515N', 10, '2026-04-24 19:15:00'),
('16161616P', 2, '2026-04-25 17:00:00'),
('99999999I', 1, '2026-04-25 11:00:00');