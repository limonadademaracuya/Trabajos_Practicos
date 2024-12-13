create database final;
drop database final;
use final;

-- 1) Crear una función llamada "calcular_total_ventas" que tome como parámetro el mes y el año, y devuelva el total de ventas realizadas en ese mes. Verificar mediante consulta.
create table ventas (
    id int auto_increment primary key,
    venta_monto decimal(10, 2),
    fecha_venta date
);

insert into  ventas (venta_monto, fecha_venta) values (100, '2023-10-05');
insert into ventas (venta_monto, fecha_venta) values (150, '2023-10-15');
insert into ventas (venta_monto, fecha_venta) values (200, '2023-10-25');
insert into ventas (venta_monto, fecha_venta) values (50, '2023-11-01');

delimiter //
create function calcular_total_ventas(mes int, anio int)
returns decimal(10, 2)
begin
    declare total decimal(10, 2);
    select coalesce(SUM(venta_monto), 0) into total from ventas
    where month(fecha_venta) = mes and year(fecha_venta) = anio;
    return total;
end
//
delimiter ;
drop function if exists calcular_total_ventas;
select calcular_total_ventas(10, 2023) as total_ventas;


-- 2) Crear una función llamada "obtener_nombre_empleado" que tome como parámetro el ID de un empleado y devuelva su nombre completo. Verificar mediante consulta.
create table empleados (
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    edad INT,
    salario DECIMAL(10, 2)
);
insert into empleados (nombre, apellido, edad, salario) values ('Juan', 'Pérez', 30, 3000);
insert into empleados (nombre, apellido, edad, salario) values ('Ana', 'García', 25, 2800);
insert into empleados (nombre, apellido, edad, salario) values ('Luis', 'Fernández', 40, 3500);
insert into empleados (nombre, apellido, edad, salario) values ('María', 'López', 35, 3200);
insert into empleados (nombre, apellido, edad, salario) values ('Pedro', 'Martínez', 29, 2900);

drop function if exists obtener_nombre_empleado;
delimiter //
CREATE FUNCTION obtener_nombre_empleado(id_empleado INT)
RETURNS VARCHAR(255)
begin
    declare nombre_completo varchar(255);
    select CONCAT(nombre, ' ', apellido) into nombre_completo
    from empleados
    where id_empleado = id_empleado;
    return nombre_completo;
end
//
delimiter ;
SELECT id_empleado, obtener_nombre_empleado(id_empleado) AS nombre_completo FROM empleados;


-- 3) Crear un procedimiento almacenado llamado "obtener_promedio" que tome como parámetro de entrada el nombre de un curso y calcule el promedio de las calificaciones de todos los alumnos inscriptos
-- en ese curso. Verificar mediante ejecución del procedimiento.
create table cursos (
    id_curso int auto_increment primary key,
    nombre_curso varchar(100) not null
);
create table alumnos (
    id_alumno int auto_increment primary key,
    nombre varchar(50) not null,
    apellido varchar(50) not null
);
create table inscripciones (
    id_inscripcion int auto_increment primary key,
    id_curso int,
    id_alumno int,
    calificacion decimal(5, 2),
    foreign key (id_curso) references cursos(id_curso),
    foreign key (id_alumno) references alumnos(id_alumno)
);
insert into cursos (nombre_curso) values
('biología'),
('química'),
('física'),
('literatura'),
('geografía'),
('arte'),
('filosofía'),
('sociología');

insert into alumnos (nombre, apellido) values
('lucas', 'torres'),
('ana', 'perez'),
('sofia', 'reyes'),
('diego', 'mendoza'),
('valentina', 'sánchez'),
('javier', 'romero'),
('camila', 'flores'),
('nicolás', 'gonzález');

insert into inscripciones (id_curso, id_alumno, calificacion) values
(1, 4, 78.0),
(2, 5, 85.0),
(3, 4, 90.5),
(1, 6, 95.0),
(2, 7, 82.0),
(3, 5, 88.5),
(1, 8, 76.0),
(2, 6, 91.0);

delimiter //
create procedure obtener_promedio (in curso_nombre varchar(100), out promedio decimal(5, 2))
begin
    select avg(calificacion) into promedio
    from inscripciones i
    join cursos c on i.id_curso = c.id_curso
    where c.nombre_curso = curso_nombre;
end //
delimiter ;

call obtener_promedio('biología', @resultado);
select @resultado as promedio_biología;


-- 4) Crear un procedimiento almacenado "actualizar_stock" que tome como parámetros de entrada el código del producto y la cantidad a agregar al stock actual.
-- El procedimiento debe actualizar el stock sumando la cantidad especificada al stock actual del producto correspondiente. Verificar mediante ejecución del procedimiento.

create table productos (
    codigo_producto int auto_increment primary key,
    nombre_producto varchar(100) not null,
    stock_actual int not null
);

insert into productos (nombre_producto, stock_actual) values
('producto a', 100),
('producto b', 40),
('producto c', 50),
('producto d', 200),
('producto e', 10);

delimiter //
create procedure actualizar_stock (
    in codigo int,
    in cantidad int
)
begin
    update productos
    set stock_actual = stock_actual + cantidad
    where codigo_producto = codigo;
end //
delimiter ;
call actualizar_stock(1, 10);
select * from productos;


-- 5) Crear una vista que muestre el título, el autor, el precio y la editorial de todos los libros 
-- de cocina de la base pubs.

CREATE VIEW vista_libros_cocina AS
SELECT
    title.t as titulo,
    au_lname.a as apellido_autor ,
    au_fname.a as nombre_autor,
    price.t as precio,
    pub_name.p as editorial
FROM
    titles t, authors a, publishers p
WHERE
    categoria = 'cocina';


-- ejercicio 6 : 
drop table fabricantes;
drop table productos;
create table fabricantes (
    id_fabricante int primary key,
    nombre_fabricante varchar(255) not null
);

insert into fabricantes (id_fabricante, nombre_fabricante)
values(1, 'fabricante a'),(2, 'fabricante b'),(3, 'fabricante c');

create table productos (
    id_producto int primary key,
    id_fabricante int,
    nombre_producto varchar(255) not null,
    fecha_lanzamiento date,
    foreign key (id_fabricante) references fabricantes(id_fabricante)
);

insert into productos (id_producto, id_fabricante, nombre_producto, fecha_lanzamiento)
values(1, 1, 'producto x', '2020-01-01'),
(2, 2, 'producto y', '2019-12-01'),
(3, 3, 'producto z', '2021-05-15');


-- 6 a)Crear un índice compuesto en las columnas id_fabricante y nombre_producto de la tabla productos.
create index idx_productos_id_fabricante_nombre  on productos (id_fabricante, nombre_producto);
show index from productos;
-- b) Crear un índice único en la columna id_producto de la tabla productos.
create index id_producto on productos (id_producto);

-- c) Modificar el índice idx_productos_id_fabricante_nombre para que sea  único en la columna id_fabricante.
drop index idx_productos_id_fabricante_nombre 
on productos;

create unique index idx_productos_id_fabricante_nombre 
on productos (id_fabricante);

-- d) Crear un nuevo índice único en la columna id_fabricante
create unique index idx_productos_id_fabricante 
on productos (id_fabricante);

--  e) Eliminar el índice idx_productos_id_fabricante de la tabla productos
drop index idx_productos_id_fabricante on productos;


/* 7)  Se desea modificar un sistema de gestión de empleados para incluir  un mecanismo automático que transfiera a 
los empleados que cumplen con ciertos criterios de jubilación a una tabla especializada llamada jubilados. 
Los criterios de jubilación son: los empleados deben tener 30 años o más de antigüedad y 65 años o más de edad. 
Además, se requiere que cualquier inserción en la tabla empleados que cumpla con estos criterios resulte en una inserción automática en la tabla jubilados.
*/
create database ejercio7;
use ejercio7;
drop database ejercio7; -- puse otra base para que no se mezclé con la tabla del ejercicio2
CREATE TABLE empleados (
  nombre VARCHAR(50) NOT NULL,
  edad INT NOT NULL,
  antiguedad INT NOT NULL
);

CREATE TABLE jubilados (
  nombre VARCHAR(50) NOT NULL,
  edad INT NOT NULL,
  antiguedad INT NOT NULL
);

delimiter //
create trigger trigger_transferir_a_jubilados
after insert on empleados
for each row
begin
  if new.edad >= 65 and new.antiguedad >= 30 then
    -- insertar automáticamente en la tabla jubilados
    insert into jubilados (nombre, edad, antiguedad)
    values (new.nombre, new.edad, new.antiguedad);
  end if;
end;
//
delimiter ;

insert into empleados (nombre, edad, antiguedad)
values ('maría lópez', 66, 35),
       ('pedro ramírez', 67, 32),
       ('luisa fernández', 70, 40);

insert into empleados (nombre, edad, antiguedad)
values  ('ana martínez', 64, 29),
       ('javier ortega', 50, 20),
       ('sofia reyes', 62, 25);

select * from jubilados;
-- 8 - Crear un procedimiento almacenado llamado ActualizarEmpleados que tome dos  parámetros de entrada:
drop table empeados; -- borrar la tabla del ejercicio 7
 CREATE TABLE empleados (
    codigo_empleado VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    salario DECIMAL(10, 2) NOT NULL
);

INSERT INTO empleados (codigo_empleado, nombre, salario)
VALUES ('empleado1', 'ana martínez', 7000.00),
       ('empleado2', 'maría lópez', 9500.00),
       ('empleado3', 'luisa fernández', 10500.00);

delimiter //

CREATE PROCEDURE ActualizarEmpleados(
    IN codigo_empleado VARCHAR(10),
    IN salario_actualizado DECIMAL(10, 2)
)
BEGIN
    DECLARE salario_actual DECIMAL(10, 2);
    DECLARE mensaje_error VARCHAR(255);
    
	-- Para manejar cualquier error que pueda llegar a ocurrir
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        SET mensaje_error = 'Ocurrió un error inesperado. Operación cancelada.';

    START TRANSACTION;

    SELECT salario INTO salario_actual
    FROM empleados
    WHERE codigo_empleado = codigo_empleado;

    IF salario_actualizado < salario_actual THEN
        SET mensaje_error = CONCAT('El nuevo salario (', salario_actualizado, ') es menor que el salario actual (', salario_actual, '). Operación cancelada.');
        ROLLBACK;
    ELSE
        -- Actualizar el salario del empleado
        UPDATE empleados
        SET salario = salario_actualizado
        WHERE codigo_empleado = codigo_empleado;
        COMMIT;
    END IF;
END;
//
delimiter ;
select * from empleados;
-- Caso exitoso: El nuevo salario es mayor que el actual
CALL ActualizarEmpleados('empleado1', 9000.00);
CALL ActualizarEmpleados('empleado2', 8500.00);
SELECT * FROM empleados;

-- ejercicios 9 : Gestión de Usuarios

-- a) Crear un usuario sin privilegios específicos
create user 'luis'@'localhost' identified by '123';

-- b) crear un usuario con privilegios de lectura sobre la base pubs
create user 'luis'@'localhost' identified by '123';
grant select on pubs.* to 'luis'@'localhost';

-- c) crear un usuario con privilegios de escritura sobre la base pubs
create user 'luis'@'localhost' identified by '123';
grant insert, update, delete on pubs.* to 'luis'@'localhost';

-- d) crear un usuario con todos los privilegios sobre la base pubs
create user 'luis'@'localhost' identified by '123';
grant all privileges on pubs.* to 'luis'@'localhost';

-- e) crear un usuario con privilegios de lectura sobre la tabla titles
create user 'ana'@'localhost' identified by '123';
grant select on pubs.titles to 'ana'@'localhost';

-- f) eliminar al usuario que tiene todos los privilegios sobre la base pubs (pobre luis)
drop user 'luis'@'localhost';

-- g) eliminar a dos usuarios a la vez
drop user 'luis'@'localhost' , 'ana'@'localhost';

-- h) eliminar un usuario y sus privilegios asociados
revoke select, insert, update, delete on pubs.* FROM 'luis'@'localhost';
DROP USER 'luis'@'localhost';

-- i) revisar los privilegios de un usuario
show grants for 'luis'@'localhost';

-- 10 – Gestor Mongo DB
-- a) Activar la base de datos "local" y luego imprimir las colecciones existentes.
use local;

-- b) Activar la base de datos "test" y luego imprimir las colecciones existentes.

-- c) Activar la base de datos "baseEjemplo2".
-- d) Mostrar las colecciones existentes en la base de datos "baseEjemplo2".
-- e) Crear otra colección llamada usuarios donde almacenar dos documentos con los campos nombre y clave.
-- f) Mostrar nuevamente las colecciones existentes en la base de datos "baseEjemplo2".

-- En la base pubs:
-- g) Insertar 2 documentos en la colección clientes con '_id' no repetidos
-- h) Intentar insertar otro documento con clave repetida.
-- i) Mostrar todos los documentos de la colección libros.

-- j) Crear una base de datos llamada "blog".
-- k) Agregar una colección llamada "posts" e insertar 1 documento con una estructura a su elección.
-- l) Mostrar todas las bases de datos actuales.
-- m) Eliminar la colección "posts"
-- n) Eliminar la base de datos "blog" y mostrar las bases de datos existentes.
