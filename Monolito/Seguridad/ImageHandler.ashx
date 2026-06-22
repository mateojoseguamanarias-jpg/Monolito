<%@ WebHandler Language="C#" Class="Monolito.Seguridad.ImageHandler" %>
using System;
using System.Web;
using System.Web.SessionState;
using Capa_Negocio;

namespace Monolito.Seguridad
{
    public class ImageHandler : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            try
            {
                
                int userId = 0;
                int fotoId = 0;

                if (context.Request.QueryString["fotoId"] != null)
                {
                    if (int.TryParse(context.Request.QueryString["fotoId"], out fotoId))
                    {
                        byte[] foto = CN_Usuario.ObtenerFotoPorId(fotoId);
                        if (foto != null && foto.Length > 0)
                        {
                            context.Response.ContentType = "image/jpeg";
                            context.Response.BinaryWrite(foto);
                            return;
                        }
                    }
                }

                if (context.Request.QueryString["id"] != null)
                {
                    int.TryParse(context.Request.QueryString["id"], out userId);
                }
                else if (context.Session["UserId"] != null)
                {
                    userId = (int)context.Session["UserId"];
                }

                if (userId > 0)
                {
                    byte[] foto = CN_Usuario.ObtenerFoto(userId);
                    if (foto != null && foto.Length > 0)
                    {
                        context.Response.ContentType = "image/jpeg";
                        context.Response.BinaryWrite(foto);
                        return;
                    }
                }
            }
            catch { }

            // Si no hay foto, devolver una imagen por defecto o nada
            context.Response.ContentType = "image/png";
            // Podríamos escribir una imagen por defecto aquí si existiera
            context.Response.End();
        }

        public bool IsReusable { get { return false; } }
    }
}
