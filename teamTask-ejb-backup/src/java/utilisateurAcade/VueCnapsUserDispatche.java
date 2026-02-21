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
public class VueCnapsUserDispatche extends ClassMAPTable {
    
    private String id_cnaps_user;
    private String code_dr;
    private String user_init;
    private String agent_mo;
    private String agent_disponible;
    private String username;
    private String code_service;
    private int    refuser;
    private String loginuser;
    private String pwduser;
    private String nomuser;
    private String adruser;
    private String teluser;
    private String idrole;

    public VueCnapsUserDispatche() {
        super.setNomTable("vuecnapsuserdispatche");
    }

    public VueCnapsUserDispatche(String id_cnaps_user,String code_dir, String user_unit, String agent_mo, String agent_disponible, String username, String code_service, int refuser, String loginuser, String pwduser, String nomuser, String adruser, String teluser, String idrole) {
         super.setNomTable("vuecnapsuserdispatche");
        this.setId_cnaps_user(id_cnaps_user);
         this.setCode_dr(code_dir);
        this.setUser_init(user_unit);
        this.setAgent_mo(agent_mo);
        this.setAgent_disponible(agent_disponible); 
        this.setUsername(username);
        this.setCode_service(code_service);
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
        return "refuser";
    }

      @Override
    public String getTuppleID() {
        return String.valueOf(refuser);
    }
    
    public String getId_cnaps_user() {
        return id_cnaps_user;
    }

    public void setId_cnaps_user(String id_cnaps_user) {
        this.id_cnaps_user = id_cnaps_user;
    }
    public String getCode_dr() {
        return code_dr;
    }

    public void setCode_dr(String code_dr) {
        this.code_dr = code_dr;
    }

    public String getUser_init() {
        return user_init;
    }

    public void setUser_init(String user_init) {
        this.user_init = user_init;
    }

    public String getAgent_mo() {
        return agent_mo;
    }

    public void setAgent_mo(String agent_mo) {
        this.agent_mo = agent_mo;
    }

    public String getAgent_disponible() {
        return agent_disponible;
    }

    public void setAgent_disponible(String agent_disponible) {
        this.agent_disponible = agent_disponible;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getCode_service() {
        return code_service;
    }

    public void setCode_service(String code_service) {
        this.code_service = code_service;
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
