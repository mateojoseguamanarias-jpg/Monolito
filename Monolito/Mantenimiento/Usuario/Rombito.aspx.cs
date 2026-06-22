using System;
using System.Web.UI;

namespace Monolito.Dashboard
{
    public partial class Rombito : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Seguridad/Loguin.aspx");
            }
        }
    }
}
