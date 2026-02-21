/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package utilisateurAcade;

import bean.ClassMAPTable;

/**
 *
 * @author Jetta
 */
public class VueCNAPSUser extends ClassMAPTable {
   /* private String code_dr;
    private String user_init;
    private String agent_mo;
    private String agent_disponible;
    private String code_service;*/
    
    private String username;
    private int refuser;
    private String loginuser;
    private String pwduser;
    private String nomuser;
    private String adruser;
    private String teluser;
    private String idrole;

    public VueCNAPSUser() {
        super.setNomTable("vuepaskuser");
    }

    public VueCNAPSUser( String username, String code_service, int refuser, String loginuser, String pwduser, String nomuser, String adruser, String teluser, String idrole) {
         super.setNomTable("vuepaskuser");
        this.setUsername(username);
        this.setRefuser(refuser);
        this.setLoginuser(loginuser);
        this.setPwduser(pwduser);
        this.setNomuser(nomuser);
        this.setAdruser(adruser);
        this.setTeluser(teluser);
        this.setIdrole(idrole);
    }
    
    

      @Override
      public String getAttributIDName() {
        return "teluser";
    }

      @Override
    public String getTuppleID() {
        return String.valueOf(teluser);
    }


    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public int getRefuser() {
        return refuser;
    }

    public void setRefuser(int refuser) {
        this.refuser = refuser;
    }

    public String getLoginuser() {
        return loginuser;
    }

    public void setLoginuser(String loginuser) {
        this.loginuser = loginuser;
    }

    public String getPwduser() {
        return pwduser;
    }

    public void setPwduser(String pwduser) {
        this.pwduser = pwduser;
    }

    public String getNomuser() {
        return nomuser;
    }

    public void setNomuser(String nomuser) {
        this.nomuser = nomuser;
    }

    public String getAdruser() {
        return adruser;
    }

    public void setAdruser(String adruser) {
        this.adruser = adruser;
    }

    public String getTeluser() {
        return teluser;
    }

    public void setTeluser(String teluser) {
        this.teluser = teluser;
    }

    public String getIdrole() {
        return idrole;
    }

    public void setIdrole(String idrole) {
        this.idrole = idrole;
    }
    
}
