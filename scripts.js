document.addEventListener('DOMContentLoaded', function() {
    const loginForm = document.getElementById('loginForm');
    const usernameInput = document.getElementById('username');
    const passwordInput = document.getElementById('password');
    const messageDiv = document.getElementById('loginMessage');

    // 🔥 Usuarios quemados
    const users = [
        { username: 'admin1', password: 'admin123', role: 'admin' },
        { username: 'mesero1', password: 'mesero123', role: 'mesero' },
        { username: 'cocinero1', password: 'cocinero123', role: 'cocinero' }
    ];

    loginForm.addEventListener('submit', function(event) {
        event.preventDefault();

        const username = usernameInput.value.trim();
        const password = passwordInput.value.trim();

        // Buscar usuario
        const userFound = users.find(user =>
            user.username === username &&
            user.password === password
        );

        if (userFound) {
            // Usuario válido -> Mostrar mensaje y redirigir según el rol
            messageDiv.textContent = `Bienvenido ${userFound.username} (${userFound.role}). Redirigiendo...`;
            messageDiv.style.color = 'green';

            setTimeout(() => {
                switch (userFound.role) {
                    case 'admin':
                        window.location.href = 'admin-index.html';
                        break;
                    case 'mesero':
                        window.location.href = 'mesero-index.html';
                        break;
                    case 'cocinero':
                        window.location.href = 'cocinero-index.html';
                        break;
                }
            }, 1000);
        } else {
            // Usuario no válido
            messageDiv.textContent = 'Usuario o contraseña incorrectos. Intenta de nuevo.';
            messageDiv.style.color = 'red';
        }
    });
});



function mostrarPago(comandaId, total) {
      document.getElementById('pagoSection').style.display = 'block';
      document.getElementById('comandaSeleccionada').innerText = comandaId;
      document.getElementById('totalPagar').innerText = total;
    }

    function confirmarPago() {
      const metodo = document.getElementById('metodoPago').value;
      const comanda = document.getElementById('comandaSeleccionada').innerText;
      alert(`✅ Comanda #${comanda} pagada con método: ${metodo.toUpperCase()}\nSe generará el Ticket.`);
      // Aquí podrías redirigir a detalleTicket.html por ejemplo:
      window.location.href = '../SeccionesMostrar/detalleTicket.html';
    }

    // detalleTicket.js - funciones del Detalle de Ticket

function imprimirTicket() {
  window.print();
}

function verificarUsuario() {
  const usuario = document.getElementById('usuario').value;
  const pin = document.getElementById('pin').value;

  // Simulación de validación (reemplazar luego con backend)
  if (usuario === "ana" && pin === "1234") {
    alert("✅ Usuario verificado. Redirigiendo a ingreso de monto inicial...");
    
    // REDIRECCIONAMOS a montoInicial.html
    window.location.href = '../Principales/montoInicial.html';
    
  } else {
    alert("❌ Usuario o PIN incorrecto. Inténtelo de nuevo.");
  }
}


function confirmarMontoInicial() {
  const monto = document.getElementById('monto_inicial').value;

  if (monto !== '' && parseFloat(monto) > 0) {
    alert(`✅ Monto inicial registrado: $${monto}\nRedirigiendo a Caja...`);
    window.location.href = '../Principales/caja.html?monto=' + encodeURIComponent(monto);
  } else {
    alert("❌ Ingrese un monto válido.");
  }
}
