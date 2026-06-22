using System;
using System.Collections.Generic;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_tipo_usuario
    {
        private CD_TipoUsuario objDatos = new CD_TipoUsuario();

        public List<TipoUsuario> ListarTipoUsuario()
        {
            return objDatos.Listar();
        }
    }
}
