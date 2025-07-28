#import "caratula.typ" : tarea, src_file

#show: tarea.with(
  title: "Proyecto de implementacion de una calculadora usando assembly",
  course: "Lenguaje Ensamblador",
  professor: "Emilio Palomino Olivera",
  authors: (
    (
      name: "Daniel R. Alegria Sallo",
      id: "215270",
    ),
  )
)

#set page(margin: 2.54cm)
#outline(title: "Tabla de Contenido")
#pagebreak()

#show heading.where(
  level:1,
): set heading(numbering: (..n) => {
  [Capitulo #n.pos().at(0):]
})

#heading(numbering: none)[Introduccion]
// 3 parrafos, reseña historica del titulo (ALU), problema, prop solucion

La Unidad Aritmético-Lógica (ALU, por sus siglas en inglés) constituye uno de
los componentes fundamentales de cualquier procesador moderno, siendo
responsable de ejecutar todas las operaciones aritméticas y lógicas que
requiere un sistema computacional. Su desarrollo se remonta a los primeros días
de la computación electrónica, cuando pioneros como John von Neumann y su
equipo conceptualizaron la arquitectura que llevaría su nombre en la década de
$1940$. Desde entonces, las ALUs han evolucionado considerablemente, incorporando
capacidades cada vez más sofisticadas para el manejo de diferentes tipos de
datos, incluyendo enteros, números en punto flotante, y operaciones en
múltiples bases numéricas. Esta evolución ha sido impulsada por la constante
demanda de mayor eficiencia computacional y la necesidad de procesar
información de manera más precisa y versátil.

En el contexto académico y profesional actual, existe una creciente necesidad
de comprender los fundamentos de las operaciones aritméticas a nivel de
hardware, especialmente cuando se trata de sistemas que deben manejar
diferentes bases numéricas y tipos de datos numéricos. Los calculadores
tradicionales y las implementaciones de software de alto nivel a menudo
abstraen estos detalles, limitando la comprensión profunda de cómo se ejecutan
realmente las operaciones matemáticas en el procesador. Esta abstracción, si
bien útil para el desarrollo de aplicaciones, representa un obstáculo para
estudiantes y profesionales que buscan entender los mecanismos subyacentes de
la computación aritmética, particularmente en escenarios que involucran
conversiones entre bases, manejo de números negativos mediante representación
en complemento a dos, y operaciones con números en punto flotante según
estándares como IEEE 754.

Para abordar esta problemática, se propone el desarrollo de una calculadora
implementada en lenguaje ensamblador que sea capaz de realizar operaciones
aritméticas básicas entre números de diferentes bases, incluyendo el soporte
completo para números en punto flotante y enteros con signo. La solución
arquitectónica elegida consiste en un servidor web desarrollado en lenguaje C
que sirve una interfaz gráfica HTML intuitiva, mientras que el núcleo
computacional se ejecuta directamente en código ensamblador. Esta aproximación
híbrida permite combinar la accesibilidad de una interfaz web moderna con la
transparencia y control total que ofrece la programación en ensamblador,
proporcionando así una herramienta educativa y práctica que expone los
mecanismos fundamentales de las operaciones aritméticas a nivel de procesador,
facilitando la comprensión de conceptos como la representación binaria, las
conversiones de base, y la implementación de algoritmos aritméticos de bajo
nivel.

#pagebreak()
= Aspectos Generales
== Descripcion del problema
// Identificacion del problema
La educación en ciencias de la computación y la ingeniería de sistemas enfrenta
un desafío significativo en la enseñanza de los fundamentos de la aritmética
computacional. Los estudiantes y profesionales a menudo interactúan con
calculadoras y sistemas de alto nivel que ocultan completamente los procesos
subyacentes de conversión entre bases numéricas, representación de números
negativos, y manejo de operaciones en punto flotante. Esta abstracción, aunque
funcional para el uso cotidiano, genera una brecha conceptual crítica que
impide la comprensión profunda de cómo los procesadores ejecutan realmente
estas operaciones.

El problema se manifiesta particularmente cuando se requiere trabajar con
sistemas embebidos, optimización de algoritmos, o depuración de código a bajo
nivel, donde el conocimiento detallado de la representación numérica y las
operaciones aritméticas resulta fundamental. Las herramientas educativas
existentes tienden a ser demasiado abstractas o, en el caso contrario,
demasiado técnicas y poco accesibles para el aprendizaje progresivo. Además, la
mayoría de las implementaciones disponibles no permiten la visualización
transparente de los procesos internos de conversión entre diferentes bases
numéricas (binaria, octal, decimal, hexadecimal) ni exponen claramente cómo se
manejan los casos especiales como el desbordamiento aritmético, la
representación en complemento a dos, o los estándares de punto flotante.

La ausencia de herramientas que combinen accesibilidad, transparencia educativa
y precisión técnica representa un obstáculo significativo para la formación
integral en computación de bajo nivel. Se requiere una solución que permita no
solo realizar cálculos aritméticos entre diferentes bases numéricas, sino que
también exponga de manera clara y comprensible los mecanismos internos de estas
operaciones, facilitando así el aprendizaje de conceptos fundamentales como la
arquitectura de procesadores, la representación de datos en memoria, y la
implementación de algoritmos aritméticos a nivel de lenguaje ensamblador.

== Objetivos
=== Objetivo General
Desarrollar una calculadora aritmética implementada en lenguaje ensamblador con
interfaz web que permita realizar operaciones matemáticas entre números de
diferentes bases numéricas, incluyendo soporte para números en punto flotante y
enteros con signo, con el propósito de proporcionar una herramienta educativa
que exponga los mecanismos fundamentales de la aritmética computacional a nivel
de procesador.

=== Objetivos Especificos
- *Implementar algoritmos aritméticos en lenguaje ensamblador* que ejecuten las
  operaciones básicas (suma, resta, multiplicación, división) para números
  enteros y en punto flotante, siguiendo los estándares de representación IEEE
  754.
- *Desarrollar funciones de conversión entre bases numéricas* que permitan
  transformar números entre sistemas binario, octal, decimal y hexadecimal,
  manteniendo la precisión y manejando casos especiales como desbordamiento
  aritmético.
- *Crear una arquitectura híbrida servidor-cliente* utilizando un servidor HTTP
  implementado en lenguaje C que sirva una interfaz gráfica HTML intuitiva,
  estableciendo comunicación eficiente entre la interfaz de usuario y el núcleo
  computacional en ensamblador.
- *Implementar manejo robusto de números negativos* mediante representación en
  complemento a dos, asegurando compatibilidad con las operaciones aritméticas
  y conversiones de base para todo el rango de valores soportados.
- *Diseñar una interfaz de usuario educativa* que visualice claramente los
  procesos internos de cálculo, incluyendo representaciones binarias
  intermedias, pasos de conversión, y resultados en múltiples bases
  simultáneamente.
- *Validar la precisión y robustez del sistema* mediante pruebas exhaustivas
  que cubran casos límite, operaciones con diferentes combinaciones de bases, y
  verificación de cumplimiento con estándares aritméticos establecidos.


== Limitaciones
// son trabajs obstaculos
El desarrollo de esta calculadora aritmética en lenguaje ensamblador presenta
varias limitaciones inherentes que constituyen obstáculos significativos para
la implementación completa del sistema. La *dependencia de la arquitectura de
procesador* representa la principal restricción, ya que el código ensamblador
está íntimamente ligado a la arquitectura específica del hardware objetivo,
limitando la portabilidad del sistema y requiriendo reimplementación para
diferentes plataformas.

La *complejidad de implementación de operaciones en punto flotante* constituye
otro obstáculo considerable, especialmente en el manejo preciso de casos
especiales como infinitos, NaN (Not a Number), y operaciones de redondeo según
el estándar IEEE 754. Esta complejidad se incrementa cuando se
requiere mantener consistencia entre diferentes bases numéricas y asegurar que
las conversiones preserven la precisión matemática esperada.

Las *limitaciones de recursos de memoria y rendimiento* imponen restricciones
adicionales, particularmente en el manejo de números de alta precisión y
operaciones que requieren múltiples conversiones de base consecutivas.
Además, la *interfaz entre el servidor C y el código
ensamblador* presenta desafíos de sincronización y transferencia de datos que
pueden afectar la estabilidad del sistema, especialmente durante operaciones
concurrentes o con cargas de trabajo intensivas.


== Delimitaciones
// el alcanze (cuantas operaciones aritmeticas me limito en usar)
El alcance del proyecto se limita específicamente a la implementación de las
*cuatro operaciones aritméticas fundamentales*: suma, resta, multiplicación y
división. Esta restricción se establece para mantener la viabilidad del
desarrollo en lenguaje ensamblador y asegurar una implementación robusta y bien
optimizada de cada operación.

Las operaciones se desarrollarán para *números enteros con signo de 32 bits* y
*números en punto flotante de precisión simple (32 bits)* según el estándar
IEEE 754, excluyendo deliberadamente operaciones más complejas como
exponenciación, logaritmos, funciones trigonométricas o raíces cuadradas.
El sistema soportará conversiones entre *bases numéricas desde
la base 2 hasta la base 16* (inclusivo), cubriendo todas las bases comúnmente
utilizadas en computación, desde binaria hasta hexadecimal.

El *rango de valores soportados* se limita a los definidos por los tipos de
datos de 32 bits, con manejo específico de casos de desbordamiento aritmético,
excluyendo deliberadamente el soporte para valores especiales de punto flotante
como infinito y NaN. No se incluirán operaciones con números de precisión
extendida ni aritmética de múltiple precisión, manteniendo el enfoque en la
demostración clara de los principios fundamentales de la aritmética
computacional.

== Justificacion
// razon por la q desarrollar
El desarrollo de esta calculadora aritmética en lenguaje ensamblador se
justifica por la creciente necesidad de comprender los fundamentos de la
computación a nivel de hardware en un contexto académico y profesional donde
las abstracciones de alto nivel dominan la enseñanza. La
implementación directa en ensamblador proporciona una *ventana transparente
hacia los mecanismos internos* de las operaciones aritméticas, permitiendo
observar cómo el procesador manipula realmente los datos binarios, ejecuta las
conversiones de base, y maneja la representación de números negativos mediante
complemento a dos.

La elección de una *arquitectura híbrida servidor-cliente* se fundamenta en la
necesidad de combinar la accesibilidad moderna con la profundidad técnica. La
interfaz web HTML permite un acceso universal sin requerir instalaciones
específicas, mientras que el núcleo en ensamblador mantiene la transparencia
educativa esencial. Esta aproximación facilita la visualización
simultánea de representaciones en múltiples bases numéricas, exponiendo
procesos que normalmente permanecen ocultos en implementaciones de software
tradicionales.

== Metodologia
// Cronograma
El cronograma real del proyecto se distribuyó en *tres fases de desarrollo*
distintas, abarcando un período total de aproximadamente 7 semanas con
intervalos de inactividad planificados:

#[
  #set par(first-line-indent: 0pt)
  *Fase 1: Implementación Base (7-8 de Junio 2025)*
  - Desarrollo inicial del servidor localhost en lenguaje C
  - Implementación básica de la interfaz gráfica de usuario
  - Integración inicial con FASM (Flat Assembler) para operaciones básicas
  - Establecimiento de la arquitectura fundamental servidor-cliente

  *Fase 2: Refinamiento de Interfaz (11-13 de Julio 2025)*
  - Implementación completa de conversiones numéricas en C como prototipo
  - Desarrollo y ajuste de la interfaz HTML con cajas de resultados
  - Preparación del código C/ensamblador para implementación final
  - Optimización de la experiencia de usuario y diseño visual

  *Fase 3: Implementación Final (24-27 de Julio 2025)*
  - Migración completa de operaciones de C hacia ensamblador (`ops.asm`)
  - Implementación correcta de operaciones en punto flotante
  - Refinamiento final del estilo de la interfaz gráfica
  - Refactorización y reorganización de archivos fuente con reglas de compilación optimizadas
  - Documentación técnica y preparación del sistema para distribución

  #figure(
    image("./imgs/showcase.png", width: 95%),
    caption: "Programa final corriendo"
  )

]

Esta metodología iterativa permitió la evolución natural del proyecto desde un
prototipo funcional hasta una implementación completa en ensamblador,
manteniendo la funcionalidad en cada iteración mientras se profundizaba
progresivamente en el nivel de implementación.


#pagebreak()
= Desarrollo del proyecto
== Sprints
=== Sprint 1: Implementación Base
El primer sprint se enfocó en establecer la arquitectura fundamental del
sistema, desarrollando los componentes básicos necesarios para la
comunicación servidor-cliente y las operaciones aritméticas iniciales.
Durante esta fase, se implementó el *servidor HTTP en
lenguaje C* utilizando sockets de Berkeley para manejar las peticiones web,
estableciendo endpoints específicos para cada operación aritmética y
configurando el sistema de archivos estáticos para servir la interfaz HTML.

El *código C inicial* incluyó la implementación de un parser básico para
procesar las peticiones HTTP POST, extraer los parámetros numéricos y las
bases especificadas, y formatear las respuestas en JSON para la interfaz
cliente. Se desarrollaron funciones auxiliares para la conversión entre
diferentes bases numéricas como prototipo, permitiendo validar la lógica de
conversión antes de su migración a ensamblador.
Paralelamente, se creó la *interfaz HTML básica* con formularios simples
que permiten la entrada de dos operandos y la selección de operación
aritmética, utilizando JavaScript para realizar peticiones asíncronas al
servidor y mostrar los resultados.

La integración inicial con *FASM (Flat Assembler)* se limitó a operaciones
básicas de suma y resta para enteros, estableciendo la interfaz de llamadas
entre C y ensamblador mediante convenciones de llamada estándar. Este
sprint concluyó con un sistema funcional capaz de realizar operaciones
aritméticas básicas, aunque con limitaciones en el manejo de diferentes
bases y tipos de datos.

=== Sprint 2: Refinamiento de Interfaz y Lógica de Conversión
El segundo sprint se centró en mejorar significativamente la experiencia de
usuario mediante la actualización de la interfaz gráfica para soportar
*entradas independientes de base numérica*. Se modificó el HTML para
incluir dos campos de entrada separados para las bases de los operandos,
permitiendo operaciones entre números de diferentes sistemas numéricos.

La interfaz se enriqueció con *cajas de resultados múltiples* que muestran
simultáneamente el resultado en diferentes bases numéricas, proporcionando
una visualización educativa completa del proceso de conversión. Se
implementaron validaciones del lado cliente en JavaScript para verificar
que los números ingresados sean válidos en sus respectivas bases, mejorando
la robustez del sistema y la experiencia de usuario.

Durante esta fase se desarrolló el *núcleo matemático del sistema* en C,
implementando funciones críticas como `str_to_base10f()` para convertir
cadenas de cualquier base (2-16) a números en punto flotante, manejando
casos especiales como números negativos, puntos decimales y dígitos
hexadecimales. La función complementaria `base10f_to_str()` realizaba la
conversión inversa desde punto flotante hacia representación de cadena en
cualquier base, implementando algoritmos de separación de parte entera y
fraccionaria con precisión configurable. Estas funciones
constituyeron la base para las operaciones transparentes entre diferentes
bases numéricas que caracterizarían el sistema final.

=== Sprint 3: Migración Completa a Ensamblador
El tercer y final sprint se enfocó exclusivamente en la *traducción
completa del código C hacia FASM*, transformando las funciones de
referencia desarrolladas en el sprint anterior en implementaciones nativas
de ensamblador. Las operaciones aritméticas básicas, que habían sido
prototipadas como funciones simples en C (`asm_fadd`, `asm_fsub`,
`asm_fmul`, `asm_fdiv`), fueron completamente reimplementadas en el módulo
`ops.asm` utilizando instrucciones del coprocesador matemático x87.

La *migración de las funciones de conversión* representó el mayor desafío
técnico, requiriendo la traducción de algoritmos complejos de manipulación
de cadenas y aritmética en punto flotante desde C hacia ensamblador puro.
Se mantuvieron exactamente los mismos algoritmos y lógica, pero
implementándolos directamente con instrucciones de procesador para
maximizar la transparencia educativa del sistema.

El sprint concluyó con *pruebas exhaustivas* comparando los resultados
entre las implementaciones C originales y las nuevas versiones en
ensamblador para validar la correctitud de la migración. Se realizó la
refactorización final del código fuente, se optimizaron las reglas de
compilación en el Makefile, y se estableció la estructura de proyecto
definitiva. El resultado final fue un sistema completamente implementado en
ensamblador que mantiene toda la funcionalidad desarrollada en los sprints
anteriores, proporcionando máxima transparencia en los procesos de cálculo
aritmético.

// == Resultados finales
// /// Explicacion del codigo
// === Backend
// === Frontend

#pagebreak()
#heading(numbering: none)[Concluciones]
// Tener tantas conclusiones como objetivos q se propuso
El desarrollo de la calculadora aritmética en lenguaje ensamblador con interfaz web alcanzó exitosamente todos los objetivos planteados, validando la viabilidad de crear herramientas educativas que combinen transparencia técnica con accesibilidad moderna.

La *implementación de algoritmos aritméticos en ensamblador* se completó
satisfactoriamente para las cuatro operaciones básicas en números enteros y
punto flotante. La migración desde prototipos en C hacia FASM expuso
directamente las instrucciones del coprocesador x87, demostrando el manejo
real de aritmética IEEE 754.

Las *funciones de conversión entre bases numéricas* lograron
transformaciones precisas entre bases 2-16, manejando correctamente números
negativos, decimales y casos de desbordamiento. Las implementaciones
`str_to_base10f()` y `base10f_to_str()` proporcionan una base sólida para
la comprensión de representaciones numéricas.

La *arquitectura híbrida servidor-cliente* demostró alta efectividad,
combinando un servidor HTTP en C con interfaz HTML que comunica
eficientemente con el núcleo en ensamblador. Esta aproximación logró
accesibilidad universal manteniendo profundidad técnica.

La *implementación de números negativos* mediante complemento a dos se
integró completamente con todas las operaciones y conversiones, asegurando
compatibilidad para el rango completo de 32 bits soportado.

La *validación del sistema* mediante pruebas exhaustivas cubrió casos
límite y diferentes combinaciones de bases. Las pruebas comparativas entre
implementaciones C y ensamblador confirmaron la correctitud de la migración
y la confiabilidad del sistema.

En conclusión, el proyecto demostró que es posible crear herramientas
técnicamente profundas sin sacrificar accesibilidad, proporcionando una
ventana única hacia los fundamentos de la aritmética computacional.

// ANEXOS
#pagebreak()
#heading(numbering: none)[Anexos]

#heading(numbering: none, level: 2)[A#h(0.5em) Repositorio del Proyecto]
#link("https://github.com/daniel-alegria3/asm-calc")

#heading(numbering: none, level: 2)[A#h(0.5em) Codigo Fuente]
#src_file("calc.c", lang: "c")
#src_file("gui.html", lang: "html")
#src_file("ops.asm", lang: "asm")

// #heading(numbering: none, level: 2)[B#h(0.5em) Generador del informe]
// #link("https://claude.ai/share/717307ad-fb75-4d0a-bf41-a4c326a660a8")

