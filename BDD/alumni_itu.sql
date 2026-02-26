--
-- PostgreSQL database dump
--

\restrict 7dz4xDoy9Q6yiXly6BIGdhzAtILmYNhhhl6gAQf23mTWjKFQPVddyrBpi4pew8b

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: actiondependante(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actiondependante(identite character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare tmp varchar; test varchar;
begin
	select string_agg(case
						when idmere = '' then null
						else idmere
						end, '-') into tmp
	from action
	where idfille = any (string_to_array(identite, '-'));

	if tmp is null then
		return rep;
	else
		select string_agg(unnest,'-') into test from unnest(string_to_array(tmp, '-'))
		where unnest = any (string_to_array(rep, '-'));
		if test is not null then
			return rep;
		end if;

		if rep is null then
			rep = tmp;
		else rep = rep||'-'||tmp;
		end if;

		return actionDependante(tmp, rep);
	end if;
end;
$$;


ALTER FUNCTION public.actiondependante(identite character varying, rep character varying) OWNER TO postgres;

--
-- Name: basedependance(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.basedependance(idbase character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar; test varchar;
 begin
	 select string_agg(idfille, ',') into tmp
	 from baserelation
	 where idmere = any (string_to_array(idbase, ','));
	 if tmp is null then
		 return rep;
	 else
		select string_agg(unnest,',') into test from unnest(string_to_array(tmp, ','))
		where unnest = any (string_to_array(rep, ','));
		if test is not null then
			return rep;
		end if;
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return basedependance(tmp, rep);
	 end if;
 end;
 $$;


ALTER FUNCTION public.basedependance(idbase character varying, rep character varying) OWNER TO postgres;

--
-- Name: basedependante(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.basedependante(idbase character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar; test varchar;
 begin
	 select string_agg(idmere, ',') into tmp
	 from baserelation
	 where idfille = any (string_to_array(idbase, ','));
	 if tmp is null then
		 return rep;
	 else
		select string_agg(unnest,',') into test from unnest(string_to_array(tmp, ','))
		where unnest = any (string_to_array(rep, ','));
		if test is not null then
			return rep;
		end if;
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return basedependante(tmp, rep);
	 end if;
 end;
 $$;


ALTER FUNCTION public.basedependante(idbase character varying, rep character varying) OWNER TO postgres;

--
-- Name: constructabsence(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.constructabsence(utilisateur_ character varying) RETURNS TABLE(id date, absence double precision)
    LANGUAGE plpgsql
    AS $$
declare r record; datytmp date; nbrejourtmp float8; nbrejourtotal float8;
begin
	for r in (select *
				from absence where utilisateur = utilisateur_) loop
																datytmp:= r.datedebut;
																nbrejourtmp:= r.nombrejour;
																nbrejourtotal:=r.nombrejour;
																	loop
																		if isJourFerie(datytmp) = 1 then
																			datytmp:= datytmp + interval '1 day';
																			continue;
																		end if;
																		if nbrejourtmp <=  0 then
																			exit;
																		end if;
																		if nbrejourtmp < 1 then
																			id:=datytmp;
																			absence:= nbrejourtmp;
																			nbrejourtmp:=0;
																		else absence:=0;
																			id:=datytmp;
																			nbrejourtmp:= nbrejourtmp - 1;
																			datytmp:= datytmp + interval '1 day';
																		end if;
																		return next;
																	end loop;
																end loop;
end;
$$;


ALTER FUNCTION public.constructabsence(utilisateur_ character varying) OWNER TO postgres;

--
-- Name: constructlistabsence(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.constructlistabsence() RETURNS TABLE(id date, utilisateur character varying, jourperdu double precision)
    LANGUAGE plpgsql
    AS $$
declare 
    r record;
    datytmp date;
    nbrejourtmp float8;
    nbrejourtotal float8;
begin
    for r in (select * from absence) loop
        datytmp := r.datedebut;
        nbrejourtmp := (r.datefin - r.datedebut) + 1;
        nbrejourtotal := nbrejourtmp;
        loop
            if isJourFerie(datytmp) = 1 then
                datytmp := datytmp + interval '1 day';
                continue;
            end if;
            if nbrejourtmp <= 0 then
                exit;
            end if;
            if nbrejourtmp < 1 then
                id := datytmp;
                jourperdu := nbrejourtmp;
                utilisateur := r.utilisateur;
                nbrejourtmp := 0;
            else
                jourperdu := 1;
                id := datytmp;
                utilisateur := r.utilisateur;
                nbrejourtmp := nbrejourtmp - 1;
                datytmp := datytmp + interval '1 day';
            end if;
            return next;
        end loop;
    end loop;
end;
$$;


ALTER FUNCTION public.constructlistabsence() OWNER TO postgres;

--
-- Name: decrement_likes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.decrement_likes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE posts SET nb_likes = nb_likes - 1 WHERE id = OLD.post_id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.decrement_likes() OWNER TO postgres;

--
-- Name: decrement_partages(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.decrement_partages() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE posts SET nb_partages = nb_partages - 1 WHERE id = OLD.post_id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.decrement_partages() OWNER TO postgres;

--
-- Name: entitedependante(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.entitedependante(identite character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare rep varchar; entitefille varchar; actionDependante varchar;
begin
	actionDependante = actionDependante(identite, null);
	if actionDependante is not null and actionDependante != '' then
		rep = actionDependante;
		identite = actionDependante || '-' || identite;
	end if;

	entitefille = entitefille(identite, null);
	if entitefille is not null and entitefille != '' then
		if rep is not null then
			rep = rep || '-' || entitefille;
		else rep = entitefille;
		end if;
	end if;

	return rep;
end;
$$;


ALTER FUNCTION public.entitedependante(identite character varying) OWNER TO postgres;

--
-- Name: entitefille(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.entitefille(identite character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare tmp varchar;
begin
	select string_agg(id, '-') into tmp
	from entite
	where idmere = any (string_to_array(identite, '-'));
	if tmp is null then
		return rep;
	else
		if rep is null then
			rep = tmp;
		else rep = rep||'-'||tmp;
		end if;
		return entitefille(tmp, rep);
	end if;
end;
$$;


ALTER FUNCTION public.entitefille(identite character varying, rep character varying) OWNER TO postgres;

--
-- Name: entitefilleclass(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.entitefilleclass(identite character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare tmp varchar;
begin
	select string_agg(id, '-') into tmp
	from entite
	where idmere = any (string_to_array(identite, '-'))
	and idcategorieniveau = any(select id
								from categorieniveau
								where idniveau = 'CLASS' and lower(val) = lower('class'));
	if tmp is null then
		return rep;
	else
		if rep is null then
			rep = tmp;
		else rep = rep||'-'||tmp;
		end if;
		return entitefilleclass(tmp, rep);
	end if;
end;
$$;


ALTER FUNCTION public.entitefilleclass(identite character varying, rep character varying) OWNER TO postgres;

--
-- Name: f_etat_devis(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_etat_devis(p_debut date, p_fin date) RETURNS TABLE(nbdevisafaire integer, nbdevisfait integer, nbdevisvalidehm integer, nbdevisvalideclient integer, nbdevis integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT
                    COUNT(*) FILTER (WHERE etat = 1)::INTEGER,
                    COUNT(*) FILTER (WHERE etat = 20)::INTEGER,
                    COUNT(*) FILTER (WHERE etat = 30)::INTEGER,
                    COUNT(*) FILTER (WHERE etat = 40)::INTEGER,
                    COUNT(*)::INTEGER
        FROM devis
        WHERE
            (p_debut IS NULL OR daty >= p_debut)
          AND
            (p_fin IS NULL OR daty <= p_fin);
END;
$$;


ALTER FUNCTION public.f_etat_devis(p_debut date, p_fin date) OWNER TO postgres;

--
-- Name: f_status_projets(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_status_projets(p_debut date, p_fin date) RETURNS TABLE(nbstandby integer, nbencours integer, nbfait integer, nbprojet integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT
                    COUNT(*) FILTER (WHERE etat = 20)::INTEGER,
                    COUNT(*) FILTER (WHERE etat = 30)::INTEGER,
                    COUNT(*) FILTER (WHERE etat = 40)::INTEGER,
                    COUNT(*)::INTEGER
        FROM creation_projet
        WHERE
            (p_debut IS NULL OR fin >= p_debut)
          AND
            (p_fin IS NULL OR debut <= p_fin);
END;
$$;


ALTER FUNCTION public.f_status_projets(p_debut date, p_fin date) OWNER TO postgres;

--
-- Name: format_minutes(double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.format_minutes(total_minutes double precision) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    h int;
    m int;
BEGIN
    h := FLOOR(total_minutes / 60)::int;
    m := MOD(FLOOR(total_minutes), 60)::int;
    RETURN h || 'H ' || m || 'min';
END;
$$;


ALTER FUNCTION public.format_minutes(total_minutes double precision) OWNER TO postgres;

--
-- Name: format_minutes(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.format_minutes(total_minutes integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    h int;
    m int;
BEGIN
    h := total_minutes / 60;
    m := total_minutes % 60;
    RETURN h || 'H ' || m || 'min';
END;
$$;


ALTER FUNCTION public.format_minutes(total_minutes integer) OWNER TO postgres;

--
-- Name: get_seq_absence(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_absence() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_absence'));
END
$$;


ALTER FUNCTION public.get_seq_absence() OWNER TO postgres;

--
-- Name: get_seq_actionprojet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_actionprojet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_ACTIONPROJET'));
        END
    $$;


ALTER FUNCTION public.get_seq_actionprojet() OWNER TO postgres;

--
-- Name: get_seq_alert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_alert() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_ALERT'));
END
$$;


ALTER FUNCTION public.get_seq_alert() OWNER TO postgres;

--
-- Name: get_seq_boutonchamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_boutonchamp() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN nextval('seq_boutonchamp');
END;
$$;


ALTER FUNCTION public.get_seq_boutonchamp() OWNER TO postgres;

--
-- Name: get_seq_boutonpage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_boutonpage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN nextval('seq_boutonpage');
END;
$$;


ALTER FUNCTION public.get_seq_boutonpage() OWNER TO postgres;

--
-- Name: get_seq_caisse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_caisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_caisse'));
END
$$;


ALTER FUNCTION public.get_seq_caisse() OWNER TO postgres;

--
-- Name: get_seq_champdynamique(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_champdynamique() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_champdynamique'));
END
$$;


ALTER FUNCTION public.get_seq_champdynamique() OWNER TO postgres;

--
-- Name: get_seq_champsspeciaux(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_champsspeciaux() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_champsspeciaux'));
END
$$;


ALTER FUNCTION public.get_seq_champsspeciaux() OWNER TO postgres;

--
-- Name: get_seq_connexion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_connexion() RETURNS integer
    LANGUAGE plpgsql
    AS $$ begin return (
select
	nextval('seq_connexion'));
end $$;


ALTER FUNCTION public.get_seq_connexion() OWNER TO postgres;

--
-- Name: get_seq_coutprevisionnel(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_coutprevisionnel() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COUTPREVISIONNEL'));
        END
    $$;


ALTER FUNCTION public.get_seq_coutprevisionnel() OWNER TO postgres;

--
-- Name: get_seq_devis(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_devis() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_DEVIS'));
        END
    $$;


ALTER FUNCTION public.get_seq_devis() OWNER TO postgres;

--
-- Name: get_seq_devisfille(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_devisfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_DEVISFILLE'));
        END
    $$;


ALTER FUNCTION public.get_seq_devisfille() OWNER TO postgres;

--
-- Name: get_seq_entitescript(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_entitescript() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_entitescript'));
		END
		$$;


ALTER FUNCTION public.get_seq_entitescript() OWNER TO postgres;

--
-- Name: get_seq_exceptiontache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_exceptiontache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_exceptiontache'));
END
    $$;


ALTER FUNCTION public.get_seq_exceptiontache() OWNER TO postgres;

--
-- Name: get_seq_histoinsert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_histoinsert() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_HistoInsert'));
        END
    $$;


ALTER FUNCTION public.get_seq_histoinsert() OWNER TO postgres;

--
-- Name: get_seq_honoraire(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_honoraire() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_HONORAIRE'));
        END
    $$;


ALTER FUNCTION public.get_seq_honoraire() OWNER TO postgres;

--
-- Name: get_seq_indisponibilite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_indisponibilite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_indisponibilite'));
END
$$;


ALTER FUNCTION public.get_seq_indisponibilite() OWNER TO postgres;

--
-- Name: get_seq_jourrepos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_jourrepos() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_jourrepos'));
END
$$;


ALTER FUNCTION public.get_seq_jourrepos() OWNER TO postgres;

--
-- Name: get_seq_magasin2(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_magasin2() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_magasin2'));
END
$$;


ALTER FUNCTION public.get_seq_magasin2() OWNER TO postgres;

--
-- Name: get_seq_mappingtypeattribut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_mappingtypeattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN nextval('seq_mappingtypeattribut');
END;
$$;


ALTER FUNCTION public.get_seq_mappingtypeattribut() OWNER TO postgres;

--
-- Name: get_seq_module(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_module() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_module'));
        END
    $$;


ALTER FUNCTION public.get_seq_module() OWNER TO postgres;

--
-- Name: get_seq_module_projet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_module_projet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_module'));
        END
    $$;


ALTER FUNCTION public.get_seq_module_projet() OWNER TO postgres;

--
-- Name: get_seq_niveauclient(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_niveauclient() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_NIVEAUCLIENT'));
        END
    $$;


ALTER FUNCTION public.get_seq_niveauclient() OWNER TO postgres;

--
-- Name: get_seq_notification(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_notification() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_notification'));
END
$$;


ALTER FUNCTION public.get_seq_notification() OWNER TO postgres;

--
-- Name: get_seq_notificationdetails(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_notificationdetails() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_NotificationDetails'));
END
$$;


ALTER FUNCTION public.get_seq_notificationdetails() OWNER TO postgres;

--
-- Name: get_seq_notificationgroupe(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_notificationgroupe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_notificationGroupe'));
END
$$;


ALTER FUNCTION public.get_seq_notificationgroupe() OWNER TO postgres;

--
-- Name: get_seq_notificationsignal(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_notificationsignal() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_notificationSignal'));
END
$$;


ALTER FUNCTION public.get_seq_notificationsignal() OWNER TO postgres;

--
-- Name: get_seq_pageanalyse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pageanalyse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN nextval('seq_pageanalyse');
END;
$$;


ALTER FUNCTION public.get_seq_pageanalyse() OWNER TO postgres;

--
-- Name: get_seq_pageanalyseattribut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pageanalyseattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN nextval('seq_pageanalyseattribut');
END;
$$;


ALTER FUNCTION public.get_seq_pageanalyseattribut() OWNER TO postgres;

--
-- Name: get_seq_pageattribut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pageattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_pageattribut'));
END
$$;


ALTER FUNCTION public.get_seq_pageattribut() OWNER TO postgres;

--
-- Name: get_seq_pagefiche(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pagefiche() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN nextval('seq_pagefiche');
END;
$$;


ALTER FUNCTION public.get_seq_pagefiche() OWNER TO postgres;

--
-- Name: get_seq_pageficheattribut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pageficheattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN nextval('seq_pageficheattribut');
END;
$$;


ALTER FUNCTION public.get_seq_pageficheattribut() OWNER TO postgres;

--
-- Name: get_seq_pageliste(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pageliste() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN nextval('seq_pageliste');
END;
$$;


ALTER FUNCTION public.get_seq_pageliste() OWNER TO postgres;

--
-- Name: get_seq_pagelisteattribut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pagelisteattribut() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN nextval('seq_pagelisteattribut');
END;
$$;


ALTER FUNCTION public.get_seq_pagelisteattribut() OWNER TO postgres;

--
-- Name: get_seq_pagesaisie(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pagesaisie() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_pagesaisie'));
END
$$;


ALTER FUNCTION public.get_seq_pagesaisie() OWNER TO postgres;

--
-- Name: get_seq_panalysechampfiltre(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_panalysechampfiltre() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN nextval('seq_panalysechampfiltre');
END;
$$;


ALTER FUNCTION public.get_seq_panalysechampfiltre() OWNER TO postgres;

--
-- Name: get_seq_pays(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pays() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_PAYS'));
        END
    $$;


ALTER FUNCTION public.get_seq_pays() OWNER TO postgres;

--
-- Name: get_seq_phaseproject(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_phaseproject() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_PHASEPROJECT'));
        END
    $$;


ALTER FUNCTION public.get_seq_phaseproject() OWNER TO postgres;

--
-- Name: get_seq_plistchampfiltre(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_plistchampfiltre() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN nextval('seq_plistchampfiltre');
END;
$$;


ALTER FUNCTION public.get_seq_plistchampfiltre() OWNER TO postgres;

--
-- Name: get_seq_pointage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_pointage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_pointage'));
        END
    $$;


ALTER FUNCTION public.get_seq_pointage() OWNER TO postgres;

--
-- Name: get_seq_projetutilisateur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_projetutilisateur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_PROJETUTILISATEUR'));
        END
    $$;


ALTER FUNCTION public.get_seq_projetutilisateur() OWNER TO postgres;

--
-- Name: get_seq_proposition(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_proposition() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_proposition'));
END
$$;


ALTER FUNCTION public.get_seq_proposition() OWNER TO postgres;

--
-- Name: get_seq_province(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_province() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_PROVINCE'));
        END
    $$;


ALTER FUNCTION public.get_seq_province() OWNER TO postgres;

--
-- Name: get_seq_qualite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_qualite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_QUALITE'));
        END
    $$;


ALTER FUNCTION public.get_seq_qualite() OWNER TO postgres;

--
-- Name: get_seq_script(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_script() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_script'));
		END
		$$;


ALTER FUNCTION public.get_seq_script() OWNER TO postgres;

--
-- Name: get_seq_scriptversionning(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_scriptversionning() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_scriptversionning'));
		END
		$$;


ALTER FUNCTION public.get_seq_scriptversionning() OWNER TO postgres;

--
-- Name: get_seq_tache_git_details(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_tache_git_details() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_tache_git_details'));
END
$$;


ALTER FUNCTION public.get_seq_tache_git_details() OWNER TO postgres;

--
-- Name: get_seq_tache_git_mere(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_tache_git_mere() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_tache_git_mere'));
END
$$;


ALTER FUNCTION public.get_seq_tache_git_mere() OWNER TO postgres;

--
-- Name: get_seq_tauxhonoraire(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_tauxhonoraire() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TAUXHONORAIRE'));
        END
    $$;


ALTER FUNCTION public.get_seq_tauxhonoraire() OWNER TO postgres;

--
-- Name: get_seq_tempstravail(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_tempstravail() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_tempstravail'));
END
$$;


ALTER FUNCTION public.get_seq_tempstravail() OWNER TO postgres;

--
-- Name: get_seq_timingapplication(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_timingapplication() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TIMINGAPPLICATION'));
        END
    $$;


ALTER FUNCTION public.get_seq_timingapplication() OWNER TO postgres;

--
-- Name: get_seq_type_utilisateur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_type_utilisateur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TYPE_UTILISATEUR'));
        END
    $$;


ALTER FUNCTION public.get_seq_type_utilisateur() OWNER TO postgres;

--
-- Name: get_seq_typechampsspeciaux(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typechampsspeciaux() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_typechampsspeciaux'));
END
$$;


ALTER FUNCTION public.get_seq_typechampsspeciaux() OWNER TO postgres;

--
-- Name: get_seq_typemagasin(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typemagasin() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_typemagasin'));
END
$$;


ALTER FUNCTION public.get_seq_typemagasin() OWNER TO postgres;

--
-- Name: get_seq_typeouinon(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typeouinon() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_typeouinon'));
END
$$;


ALTER FUNCTION public.get_seq_typeouinon() OWNER TO postgres;

--
-- Name: get_seq_typepageliste(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typepageliste() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN nextval('seq_typepageliste');
END;
$$;


ALTER FUNCTION public.get_seq_typepageliste() OWNER TO postgres;

--
-- Name: get_seq_typepagesaisie(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typepagesaisie() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_typepagesaisie'));
END
$$;


ALTER FUNCTION public.get_seq_typepagesaisie() OWNER TO postgres;

--
-- Name: get_seq_typeplistchampfiltre(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typeplistchampfiltre() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN nextval('seq_typeplistchampfiltre');
END;
$$;


ALTER FUNCTION public.get_seq_typeplistchampfiltre() OWNER TO postgres;

--
-- Name: get_seq_typescript(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typescript() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_typescript'));
		END
		$$;


ALTER FUNCTION public.get_seq_typescript() OWNER TO postgres;

--
-- Name: get_seq_typetache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seq_typetache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_typetache'));
        END
    $$;


ALTER FUNCTION public.get_seq_typetache() OWNER TO postgres;

--
-- Name: get_seqattacher_fichier(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqattacher_fichier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqattacher_fichier'));
END
$$;


ALTER FUNCTION public.get_seqattacher_fichier() OWNER TO postgres;

--
-- Name: get_seqbranche(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqbranche() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqbranche'));
END
$$;


ALTER FUNCTION public.get_seqbranche() OWNER TO postgres;

--
-- Name: get_seqclient(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqclient() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqclient'));
END
$$;


ALTER FUNCTION public.get_seqclient() OWNER TO postgres;

--
-- Name: get_seqdiagramclass(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramclass() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramClass'));
END
$$;


ALTER FUNCTION public.get_seqdiagramclass() OWNER TO postgres;

--
-- Name: get_seqdiagramclasscomposant(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramclasscomposant() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramClassComposant'));
END
$$;


ALTER FUNCTION public.get_seqdiagramclasscomposant() OWNER TO postgres;

--
-- Name: get_seqdiagramclasscomposanttype(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramclasscomposanttype() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramClassComposantType'));
END
$$;


ALTER FUNCTION public.get_seqdiagramclasscomposanttype() OWNER TO postgres;

--
-- Name: get_seqdiagramclasspackage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramclasspackage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramClassPackage'));
END
$$;


ALTER FUNCTION public.get_seqdiagramclasspackage() OWNER TO postgres;

--
-- Name: get_seqdiagramcomposant(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramcomposant() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramComposant'));
END
$$;


ALTER FUNCTION public.get_seqdiagramcomposant() OWNER TO postgres;

--
-- Name: get_seqdiagrampackage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagrampackage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramPackage'));
END
$$;


ALTER FUNCTION public.get_seqdiagrampackage() OWNER TO postgres;

--
-- Name: get_seqdiagramtable(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramtable() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramTable'));
END
$$;


ALTER FUNCTION public.get_seqdiagramtable() OWNER TO postgres;

--
-- Name: get_seqdiagramtablecolonne(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqdiagramtablecolonne() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramTableColonne'));
END
$$;


ALTER FUNCTION public.get_seqdiagramtablecolonne() OWNER TO postgres;

--
-- Name: get_seqexecution_script(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqexecution_script() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqEXECUTION_SCRIPT'));
END
$$;


ALTER FUNCTION public.get_seqexecution_script() OWNER TO postgres;

--
-- Name: get_seqexecution_scriptfille(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqexecution_scriptfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqEXECUTION_SCRIPTFILLE'));
END
$$;


ALTER FUNCTION public.get_seqexecution_scriptfille() OWNER TO postgres;

--
-- Name: get_seqexternal_work(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqexternal_work() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqexternal_work'));
END
$$;


ALTER FUNCTION public.get_seqexternal_work() OWNER TO postgres;

--
-- Name: get_seqfonctionnalite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqfonctionnalite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqfonctionnalite'));
END
$$;


ALTER FUNCTION public.get_seqfonctionnalite() OWNER TO postgres;

--
-- Name: get_seqpage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqpage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqpage'));
END
$$;


ALTER FUNCTION public.get_seqpage() OWNER TO postgres;

--
-- Name: get_seqparamcrypt(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqparamcrypt() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqparamcrypt'));
END
$$;


ALTER FUNCTION public.get_seqparamcrypt() OWNER TO postgres;

--
-- Name: get_seqpiecejointe(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqpiecejointe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqpieceJointe'));
END
$$;


ALTER FUNCTION public.get_seqpiecejointe() OWNER TO postgres;

--
-- Name: get_seqprojet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqprojet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqprojet'));
END
$$;


ALTER FUNCTION public.get_seqprojet() OWNER TO postgres;

--
-- Name: get_seqscript_projet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqscript_projet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqscript_projet'));
END
$$;


ALTER FUNCTION public.get_seqscript_projet() OWNER TO postgres;

--
-- Name: get_seqtachemere(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqtachemere() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqtacheMere'));
END
$$;


ALTER FUNCTION public.get_seqtachemere() OWNER TO postgres;

--
-- Name: get_seqtachemere_detailsdefaut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqtachemere_detailsdefaut() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TAUXHONORAIRE'));
        END
    $$;


ALTER FUNCTION public.get_seqtachemere_detailsdefaut() OWNER TO postgres;

--
-- Name: get_seqtachemeredefaut(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqtachemeredefaut() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_TAUXHONORAIRE'));
        END
    $$;


ALTER FUNCTION public.get_seqtachemeredefaut() OWNER TO postgres;

--
-- Name: get_seqtimingsoustache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqtimingsoustache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seq_TIMINGSOUSTACHE'));
END
$$;


ALTER FUNCTION public.get_seqtimingsoustache() OWNER TO postgres;

--
-- Name: get_seqtypefichier(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqtypefichier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqtypeFichier'));
END
$$;


ALTER FUNCTION public.get_seqtypefichier() OWNER TO postgres;

--
-- Name: get_seqwork_branche(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqwork_branche() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqwork_branche'));
END
$$;


ALTER FUNCTION public.get_seqwork_branche() OWNER TO postgres;

--
-- Name: get_seqwork_type(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_seqwork_type() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqwork_type'));
END
$$;


ALTER FUNCTION public.get_seqwork_type() OWNER TO postgres;

--
-- Name: getattributclasse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getattributclasse() RETURNS integer
    LANGUAGE sql
    AS $$
SELECT nextval('seq_attributclasse')::integer;
$$;


ALTER FUNCTION public.getattributclasse() OWNER TO postgres;

--
-- Name: getcategorieniveau(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getcategorieniveau() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqcategorieniveau'));
END
$$;


ALTER FUNCTION public.getcategorieniveau() OWNER TO postgres;

--
-- Name: getheuresup(date, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getheuresup(daty_ date, debut_ timestamp without time zone, fin_ timestamp without time zone) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
	declare rep float8;
			dmatin time;
			fmatin time;
			dapresmidi time;
			fapresmidi time;
			refs time;
			refsdebut timestamp;
			refsfin timestamp;
			dmatinref timestamp;
			fmatinref timestamp;
			dapresmidiref timestamp;
			fapresmidiref timestamp;
			tmp timestamp;
begin
	select cast(debutmatin as time), cast(finmatin as time), cast(debutapresmidi as time), cast(finapresmidi as time) into dmatin, fmatin, dapresmidi, fapresmidi
				from tempstravail t where id in(
					select max(id) from "tempstravail" c where daty in (
						select max(daty) from tempstravail where daty<=daty_));
	rep = 0;
	if debut_>=fin_ then
		return rep;
	end if;

	if cast(debut_ as time) >= fapresmidi and cast(fin_ as time) >= fapresmidi and date(debut_) = date(fin_) then
		rep = rep + date_part('epoch'::text, fin_ - debut_)/60;
	elsif cast(debut_ as time) >= fapresmidi and cast(fin_ as time) <= dmatin and date(fin_) = (date(debut_) + '1 day'::interval) then
		rep = rep + date_part('epoch'::text, '24:00'::time - cast(debut_ as time))/60 + date_part('epoch'::text, cast(fin_ as time) - '00:00'::time) /60;
	elsif cast(debut_ as time) <= dmatin and cast(fin_ as time) <= dmatin and date(debut_) = date(fin_) then
	 		rep = rep + date_part('epoch'::text, fin_ - debut_)/60;
	elsif cast(debut_ as time) >= fmatin and cast(debut_ as time) <= dapresmidi and cast(fin_ as time) >= fmatin and cast(fin_ as time) <= dapresmidi and date(debut_) = date(fin_) then
			rep = rep + date_part('epoch'::text, fin_ - debut_)/60;
	else
		refs = cast(debut_ as time);
		refsdebut = date(debut_);
		if refs = dmatin or refs = fmatin or refs = dapresmidi or refs = fapresmidi then
			refsdebut = debut_;
		else
			if refs>=fapresmidi or refs<=dmatin then
				if refs<='24:00'::time and refs>=fapresmidi then
					rep = rep + date_part('epoch'::text, '24:00'::time - refs)/60;
					refs = '00:00'::time;
					refsdebut = refsdebut  + '1 day'::interval;
				end if;
				if refs<=dmatin and refs>='00:00'::time then
					rep = rep + date_part('epoch'::text, dmatin - refs)/60;
					refsdebut = refsdebut + dmatin;
				end if;
			end if;
			if refs>=fmatin and refs<=dapresmidi then
				if refs != dapresmidi then
					rep = rep + date_part('epoch'::text, dapresmidi - refs)/60;
				end if;
				refsdebut = refsdebut + dapresmidi;
			end if;
			if refs>=dmatin and refs<=fmatin then
				refsdebut = refsdebut + fmatin;
			end if;
			if refs>=dapresmidi and refs<=fapresmidi then
				refsdebut = refsdebut + fapresmidi;
			end if;
		end if;

		refs = cast (fin_ as time);
		refsfin = date(fin_);
		if refs>=fapresmidi or refs<=dmatin then
			if refs<=dmatin and refs>='00:00'::time then
				rep = rep + date_part('epoch'::text, refs - '00:00'::time)/60;
				refs = '24:00'::time;
				refsfin = refsfin - '1 day'::interval;
			end if;
			if refs<='24:00'::time and refs>=fapresmidi then
				rep = rep + date_part('epoch'::text, refs - fapresmidi)/60;
				refsfin = refsfin + fapresmidi;
			end if;
		end if;
		if refs>=fmatin and refs<=dapresmidi then
			if refs != dapresmidi then
				rep = rep + date_part('epoch'::text, refs - fmatin)/60;
			end if;
			refsfin = refsfin + fmatin;
		end if;
		if refs>=dmatin and refs<=fmatin then
			refsfin = refsfin + dmatin;
		end if;
		if refs>=dapresmidi and refs<=fapresmidi then
			refsfin = refsfin + dapresmidi;
		end if;

		tmp = date(refsdebut);
		loop
				if date(refsfin) < tmp then
					exit;
				end if;
				dmatinref = tmp::timestamp + dmatin;
				fmatinref = tmp::timestamp + fmatin;
				dapresmidiref = tmp::timestamp + dapresmidi;
				fapresmidiref = tmp::timestamp + fapresmidi;
				if fmatinref>=refsdebut and dapresmidiref<=refsfin then
					rep = rep + date_part('epoch'::text, dapresmidiref - fmatinref)/60;
				end if;
				if fapresmidiref>=refsdebut and ((date(fapresmidiref) + '1 day'::interval)::timestamp + dmatin)<=refsfin then
					rep = rep + date_part('epoch'::text, ((date(fapresmidiref) + '1 day'::interval)::timestamp + dmatin) - fapresmidiref)/60;
				end if;
				tmp = tmp + '1 day'::interval;
		end loop;
	end if;

	return rep;
end;
$$;


ALTER FUNCTION public.getheuresup(daty_ date, debut_ timestamp without time zone, fin_ timestamp without time zone) OWNER TO postgres;

--
-- Name: getheuretravailmax(date, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getheuretravailmax(daty_ date, unite character varying) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
	declare rep float8;
			dmatin time;
			fmatin time;
			dapresmidi time;
			fapresmidi time;

begin
	select cast(debutmatin as time), cast(finmatin as time), cast(debutapresmidi as time), cast(finapresmidi as time) into dmatin, fmatin, dapresmidi, fapresmidi
				from tempstravail t where id in(
					select max(id) from "tempstravail" c where daty in (
						select max(daty) from tempstravail where daty<=daty_));
	rep = 0;
	rep = (date_part('epoch'::text, fmatin - dmatin)/60) + date_part('epoch'::text, fapresmidi - dapresmidi)/60;

	if unite = 'h' then
		rep = rep/60;
	end if;
	return rep;
end;
$$;


ALTER FUNCTION public.getheuretravailmax(daty_ date, unite character varying) OWNER TO postgres;

--
-- Name: getseq_analyses(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_analyses() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_analyses'));
END;
$$;


ALTER FUNCTION public.getseq_analyses() OWNER TO postgres;

--
-- Name: getseq_apjclasse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_apjclasse() RETURNS integer
    LANGUAGE sql
    AS $$
SELECT nextval('seq_apjclasse')::integer;
$$;


ALTER FUNCTION public.getseq_apjclasse() OWNER TO postgres;

--
-- Name: getseq_attacher_fichier(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_attacher_fichier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqattacher_fichier'));
END
$$;


ALTER FUNCTION public.getseq_attacher_fichier() OWNER TO postgres;

--
-- Name: getseq_attribusentite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_attribusentite() RETURNS integer
    LANGUAGE sql
    AS $$
    SELECT nextval('seq_attribusentite')::integer;
$$;


ALTER FUNCTION public.getseq_attribusentite() OWNER TO postgres;

--
-- Name: getseq_attributoracle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_attributoracle() RETURNS integer
    LANGUAGE sql
    AS $$
    SELECT nextval('seq_attributoracle')::integer;
$$;


ALTER FUNCTION public.getseq_attributoracle() OWNER TO postgres;

--
-- Name: getseq_attributpostgres(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_attributpostgres() RETURNS integer
    LANGUAGE sql
    AS $$
    SELECT nextval('seq_attributpostgres')::integer;
$$;


ALTER FUNCTION public.getseq_attributpostgres() OWNER TO postgres;

--
-- Name: getseq_attributtype(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_attributtype() RETURNS integer
    LANGUAGE sql
    AS $$
    SELECT nextval('seq_attributtype')::integer;
$$;


ALTER FUNCTION public.getseq_attributtype() OWNER TO postgres;

--
-- Name: getseq_cheminprojetuser(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_cheminprojetuser() RETURNS integer
    LANGUAGE sql
    AS $$
    SELECT nextval('seq_cheminprojetuser')::integer;
$$;


ALTER FUNCTION public.getseq_cheminprojetuser() OWNER TO postgres;

--
-- Name: getseq_diagramaffichage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_diagramaffichage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_DiagramAffichage'));
END
$$;


ALTER FUNCTION public.getseq_diagramaffichage() OWNER TO postgres;

--
-- Name: getseq_diagramtable(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_diagramtable() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramTable'));
END
$$;


ALTER FUNCTION public.getseq_diagramtable() OWNER TO postgres;

--
-- Name: getseq_diagramtablecolonne(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_diagramtablecolonne() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_diagramTableColonne'));
END
$$;


ALTER FUNCTION public.getseq_diagramtablecolonne() OWNER TO postgres;

--
-- Name: getseq_histoinsert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_histoinsert() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    retour BIGINT;
BEGIN
    SELECT nextval('seq_histoinsert') INTO retour;
    RETURN retour;
END;
$$;


ALTER FUNCTION public.getseq_histoinsert() OWNER TO postgres;

--
-- Name: getseq_proposition(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_proposition() RETURNS integer
    LANGUAGE sql
    AS $$
SELECT nextval('seq_proposition')::integer;
$$;


ALTER FUNCTION public.getseq_proposition() OWNER TO postgres;

--
-- Name: getseq_relation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_relation() RETURNS integer
    LANGUAGE sql
    AS $$
    SELECT nextval('seq_relation')::integer;
$$;


ALTER FUNCTION public.getseq_relation() OWNER TO postgres;

--
-- Name: getseq_serveur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_serveur() RETURNS integer
    LANGUAGE sql
    AS $$
     SELECT nextval('seq_serveur')::integer;
$$;


ALTER FUNCTION public.getseq_serveur() OWNER TO postgres;

--
-- Name: getseq_typeclasse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_typeclasse() RETURNS integer
    LANGUAGE sql
    AS $$
SELECT nextval('seq_typeclasse')::integer;
$$;


ALTER FUNCTION public.getseq_typeclasse() OWNER TO postgres;

--
-- Name: getseq_typedependancediagram(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_typedependancediagram() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_typeDependanceDiagram'));
END
$$;


ALTER FUNCTION public.getseq_typedependancediagram() OWNER TO postgres;

--
-- Name: getseq_typedependanceobjet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_typedependanceobjet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_typeDependanceObjet'));
END
$$;


ALTER FUNCTION public.getseq_typedependanceobjet() OWNER TO postgres;

--
-- Name: getseq_typeliaison(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_typeliaison() RETURNS integer
    LANGUAGE sql
    AS $$
    SELECT nextval('seq_typeliaison')::integer;
$$;


ALTER FUNCTION public.getseq_typeliaison() OWNER TO postgres;

--
-- Name: getseq_typerelation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_typerelation() RETURNS integer
    LANGUAGE sql
    AS $$
    SELECT nextval('seq_typerelation')::integer;
$$;


ALTER FUNCTION public.getseq_typerelation() OWNER TO postgres;

--
-- Name: getseq_v_classeetfiche(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_v_classeetfiche() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    retour BIGINT;
BEGIN
    SELECT nextval('seq_v_classeetfiche') INTO retour;
    RETURN retour;
END;
$$;


ALTER FUNCTION public.getseq_v_classeetfiche() OWNER TO postgres;

--
-- Name: getseq_v_classetfiche(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseq_v_classetfiche() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_v_ClassEtFiche'));
        END
    $$;


ALTER FUNCTION public.getseq_v_classetfiche() OWNER TO postgres;

--
-- Name: getseqaction(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqaction() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqaction')); END $$;


ALTER FUNCTION public.getseqaction() OWNER TO postgres;

--
-- Name: getseqactiontache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqactiontache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqactionTache'));
END
$$;


ALTER FUNCTION public.getseqactiontache() OWNER TO postgres;

--
-- Name: getseqannulationutilisateur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqannulationutilisateur() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqannulationutilisateur')); END $$;


ALTER FUNCTION public.getseqannulationutilisateur() OWNER TO postgres;

--
-- Name: getseqarchitecture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqarchitecture() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqarchitecture'));
 END
 $$;


ALTER FUNCTION public.getseqarchitecture() OWNER TO postgres;

--
-- Name: getseqavoirfc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqavoirfc() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQAVOIRFC'));
END
$$;


ALTER FUNCTION public.getseqavoirfc() OWNER TO postgres;

--
-- Name: getseqavoirfcfille(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqavoirfcfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQAVOIRFCFILLE'));
END
$$;


ALTER FUNCTION public.getseqavoirfcfille() OWNER TO postgres;

--
-- Name: getseqbase(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqbase() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqbase'));
 END
 $$;


ALTER FUNCTION public.getseqbase() OWNER TO postgres;

--
-- Name: getseqbaserelation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqbaserelation() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqbaserelation'));
 END
 $$;


ALTER FUNCTION public.getseqbaserelation() OWNER TO postgres;

--
-- Name: getseqbranche(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqbranche() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_branche'));
		END
		$$;


ALTER FUNCTION public.getseqbranche() OWNER TO postgres;

--
-- Name: getseqcaisse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQCAISSE'));
END
$$;


ALTER FUNCTION public.getseqcaisse() OWNER TO postgres;

--
-- Name: getseqcalendrierscolaire(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcalendrierscolaire() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN nextval('seq_calendrier_scolaire');
END;
$$;


ALTER FUNCTION public.getseqcalendrierscolaire() OWNER TO postgres;

--
-- Name: getseqcanevatache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcanevatache() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN nextval('seqCanevaTache');
END;
$$;


ALTER FUNCTION public.getseqcanevatache() OWNER TO postgres;

--
-- Name: getseqcateging(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcateging() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQCATEGING'));
END
$$;


ALTER FUNCTION public.getseqcateging() OWNER TO postgres;

--
-- Name: getseqcategorie(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcategorie() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('Seqcategorie'));
END;
$$;


ALTER FUNCTION public.getseqcategorie() OWNER TO postgres;

--
-- Name: getseqcategorieactivite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcategorieactivite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_categorie_activite'));
END $$;


ALTER FUNCTION public.getseqcategorieactivite() OWNER TO postgres;

--
-- Name: getseqcategorieavoirfc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcategorieavoirfc() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQCATEGORIEAVOIRFC'));
END
$$;


ALTER FUNCTION public.getseqcategorieavoirfc() OWNER TO postgres;

--
-- Name: getseqcategoriecaisse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcategoriecaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqcategoriecaisse'));
END
$$;


ALTER FUNCTION public.getseqcategoriecaisse() OWNER TO postgres;

--
-- Name: getseqclasse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqclasse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_classe'));
END
$$;


ALTER FUNCTION public.getseqclasse() OWNER TO postgres;

--
-- Name: getseqclient(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqclient() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqclient'));
END
$$;


ALTER FUNCTION public.getseqclient() OWNER TO postgres;

--
-- Name: getseqcommentaires(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcommentaires() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_commentaires')); 
END $$;


ALTER FUNCTION public.getseqcommentaires() OWNER TO postgres;

--
-- Name: getseqcompetence(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcompetence() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqcompetence')); END $$;


ALTER FUNCTION public.getseqcompetence() OWNER TO postgres;

--
-- Name: getseqcomptaclassecompte(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptaclassecompte() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTACLASSECOMPTE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptaclassecompte() OWNER TO postgres;

--
-- Name: getseqcomptacompte(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptacompte() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTACOMPTE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptacompte() OWNER TO postgres;

--
-- Name: getseqcomptacomptebackup(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptacomptebackup() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTACOMPTEBACKUP'));
        END
    $$;


ALTER FUNCTION public.getseqcomptacomptebackup() OWNER TO postgres;

--
-- Name: getseqcomptaecriture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptaecriture() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAECRITURE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptaecriture() OWNER TO postgres;

--
-- Name: getseqcomptaecriturebackup(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptaecriturebackup() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAECRITUREBACKUP'));
        END
    $$;


ALTER FUNCTION public.getseqcomptaecriturebackup() OWNER TO postgres;

--
-- Name: getseqcomptaexercice(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptaexercice() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAEXERCICE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptaexercice() OWNER TO postgres;

--
-- Name: getseqcomptajournal(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptajournal() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAJOURNAL'));
        END
    $$;


ALTER FUNCTION public.getseqcomptajournal() OWNER TO postgres;

--
-- Name: getseqcomptajournalbackup(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptajournalbackup() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAJOURNALBACKUP'));
        END
    $$;


ALTER FUNCTION public.getseqcomptajournalbackup() OWNER TO postgres;

--
-- Name: getseqcomptalettrage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptalettrage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTALETTRAGE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptalettrage() OWNER TO postgres;

--
-- Name: getseqcomptaorigine(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptaorigine() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTAORIGINE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptaorigine() OWNER TO postgres;

--
-- Name: getseqcomptasousecriture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptasousecriture() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTASOUSECRITURE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptasousecriture() OWNER TO postgres;

--
-- Name: getseqcomptasousecriturebackup(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptasousecriturebackup() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTASOUSECRITUREBACKUP'));
        END
    $$;


ALTER FUNCTION public.getseqcomptasousecriturebackup() OWNER TO postgres;

--
-- Name: getseqcomptatypecompte(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcomptatypecompte() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_COMPTATYPECOMPTE'));
        END
    $$;


ALTER FUNCTION public.getseqcomptatypecompte() OWNER TO postgres;

--
-- Name: getseqconception_pm(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqconception_pm() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_Conception_PM'));
END
$$;


ALTER FUNCTION public.getseqconception_pm() OWNER TO postgres;

--
-- Name: getseqcote(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcote() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('SeqCote'));
END;
$$;


ALTER FUNCTION public.getseqcote() OWNER TO postgres;

--
-- Name: getseqcrcontent(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcrcontent() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqCRContent')); END $$;


ALTER FUNCTION public.getseqcrcontent() OWNER TO postgres;

--
-- Name: getseqcrcontentfille(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcrcontentfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqCRContentFille')); END $$;


ALTER FUNCTION public.getseqcrcontentfille() OWNER TO postgres;

--
-- Name: getseqcreation_projet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcreation_projet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('SeqCreation_projet'));
END;
$$;


ALTER FUNCTION public.getseqcreation_projet() OWNER TO postgres;

--
-- Name: getseqdeploiement(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqdeploiement() RETURNS integer
    LANGUAGE plpgsql
    AS $$
		BEGIN
		RETURN (SELECT nextval('seq_deploiement'));
		END
		$$;


ALTER FUNCTION public.getseqdeploiement() OWNER TO postgres;

--
-- Name: getseqdevise(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqdevise() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqdevise'));
END
$$;


ALTER FUNCTION public.getseqdevise() OWNER TO postgres;

--
-- Name: getseqdiplome(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqdiplome() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqdiplome')); END $$;


ALTER FUNCTION public.getseqdiplome() OWNER TO postgres;

--
-- Name: getseqdomaine(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqdomaine() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqdomaine')); END $$;


ALTER FUNCTION public.getseqdomaine() OWNER TO postgres;

--
-- Name: getseqecole(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqecole() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqecole')); END $$;


ALTER FUNCTION public.getseqecole() OWNER TO postgres;

--
-- Name: getseqentite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqentite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqentite'));
END
$$;


ALTER FUNCTION public.getseqentite() OWNER TO postgres;

--
-- Name: getseqentreprise(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqentreprise() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_entreprise')); 
END $$;


ALTER FUNCTION public.getseqentreprise() OWNER TO postgres;

--
-- Name: getseqequipe(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqequipe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqequipe'));
END;
$$;


ALTER FUNCTION public.getseqequipe() OWNER TO postgres;

--
-- Name: getseqexecutions(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqexecutions() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN nextval('seqphase');  -- gets the next value from the sequence
END;
$$;


ALTER FUNCTION public.getseqexecutions() OWNER TO postgres;

--
-- Name: getseqexperience(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqexperience() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqexperience')); END $$;


ALTER FUNCTION public.getseqexperience() OWNER TO postgres;

--
-- Name: getseqfonctionnalite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqfonctionnalite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqfonctionnalite'));
END
$$;


ALTER FUNCTION public.getseqfonctionnalite() OWNER TO postgres;

--
-- Name: getseqfournisseur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqfournisseur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQFOURNISSEUR'));
END
$$;


ALTER FUNCTION public.getseqfournisseur() OWNER TO postgres;

--
-- Name: getseqgroupemembres(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqgroupemembres() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqgroupemembres')); END $$;


ALTER FUNCTION public.getseqgroupemembres() OWNER TO postgres;

--
-- Name: getseqgroupes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqgroupes() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqgroupes')); END $$;


ALTER FUNCTION public.getseqgroupes() OWNER TO postgres;

--
-- Name: getseqhistoimport(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqhistoimport() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqhistoimport'));
END
    $$;


ALTER FUNCTION public.getseqhistoimport() OWNER TO postgres;

--
-- Name: getseqhistorique(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqhistorique() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqhistorique')); END $$;


ALTER FUNCTION public.getseqhistorique() OWNER TO postgres;

--
-- Name: getseqhistoriqueactif(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqhistoriqueactif() RETURNS bigint
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN nextval('seqHistoriqueActif');
END;
$$;


ALTER FUNCTION public.getseqhistoriqueactif() OWNER TO postgres;

--
-- Name: getseqhistoriquevaleur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqhistoriquevaleur() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqhistoriquevaleur')); END $$;


ALTER FUNCTION public.getseqhistoriquevaleur() OWNER TO postgres;

--
-- Name: getseqhistovaleur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqhistovaleur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('seqhistovaleur'));
END;
$$;


ALTER FUNCTION public.getseqhistovaleur() OWNER TO postgres;

--
-- Name: getseqingredients(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqingredients() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQINGREDIENTS'));
END
$$;


ALTER FUNCTION public.getseqingredients() OWNER TO postgres;

--
-- Name: getseqlikes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqlikes() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_likes')); 
END $$;


ALTER FUNCTION public.getseqlikes() OWNER TO postgres;

--
-- Name: getseqmagasin(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmagasin() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQMAGASIN'));
END
$$;


ALTER FUNCTION public.getseqmagasin() OWNER TO postgres;

--
-- Name: getseqmailcc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmailcc() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqmailcc')); END $$;


ALTER FUNCTION public.getseqmailcc() OWNER TO postgres;

--
-- Name: getseqmailrapport(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmailrapport() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqMailRapport')); END $$;


ALTER FUNCTION public.getseqmailrapport() OWNER TO postgres;

--
-- Name: getseqmenudynamique(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmenudynamique() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqmenudynamique')); END $$;


ALTER FUNCTION public.getseqmenudynamique() OWNER TO postgres;

--
-- Name: getseqmetier(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmetier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqmetier'));
 END
 $$;


ALTER FUNCTION public.getseqmetier() OWNER TO postgres;

--
-- Name: getseqmetierfille(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmetierfille() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_MetierFille'));
END
$$;


ALTER FUNCTION public.getseqmetierfille() OWNER TO postgres;

--
-- Name: getseqmetierrelation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmetierrelation() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqmetierrelation'));
 END
 $$;


ALTER FUNCTION public.getseqmetierrelation() OWNER TO postgres;

--
-- Name: getseqmoderationutilisateur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmoderationutilisateur() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqmoderationutilisateur')); END $$;


ALTER FUNCTION public.getseqmoderationutilisateur() OWNER TO postgres;

--
-- Name: getseqmodule(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmodule() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_module'));
        END
    $$;


ALTER FUNCTION public.getseqmodule() OWNER TO postgres;

--
-- Name: getseqmotifavoirfc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmotifavoirfc() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQMOTIFAVOIRFC'));
END
$$;


ALTER FUNCTION public.getseqmotifavoirfc() OWNER TO postgres;

--
-- Name: getseqmotifsignalement(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmotifsignalement() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_motif_signalement')); 
END $$;


ALTER FUNCTION public.getseqmotifsignalement() OWNER TO postgres;

--
-- Name: getseqmouvementcaisse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmouvementcaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQMOUVEMENTCAISSE'));
END
$$;


ALTER FUNCTION public.getseqmouvementcaisse() OWNER TO postgres;

--
-- Name: getseqmvtcaisseprevision(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmvtcaisseprevision() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqmvtcaisseprevision'));
END
$$;


ALTER FUNCTION public.getseqmvtcaisseprevision() OWNER TO postgres;

--
-- Name: getseqniveau(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqniveau() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqniveau'));
END
$$;


ALTER FUNCTION public.getseqniveau() OWNER TO postgres;

--
-- Name: getseqnotificationaction(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqnotificationaction() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqnotificationAction'));
END
$$;


ALTER FUNCTION public.getseqnotificationaction() OWNER TO postgres;

--
-- Name: getseqnotifications(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqnotifications() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_notifications')); 
END $$;


ALTER FUNCTION public.getseqnotifications() OWNER TO postgres;

--
-- Name: getseqoption(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqoption() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqoption')); END $$;


ALTER FUNCTION public.getseqoption() OWNER TO postgres;

--
-- Name: getseqordonnerpaiement(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqordonnerpaiement() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqordonnerpaiement'));
END
$$;


ALTER FUNCTION public.getseqordonnerpaiement() OWNER TO postgres;

--
-- Name: getseqpagerelation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqpagerelation() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqpagerelation'));
 END
 $$;


ALTER FUNCTION public.getseqpagerelation() OWNER TO postgres;

--
-- Name: getseqparamcrypt(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqparamcrypt() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqparamcrypt')); END $$;


ALTER FUNCTION public.getseqparamcrypt() OWNER TO postgres;

--
-- Name: getseqparcours(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqparcours() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqparcours')); END $$;


ALTER FUNCTION public.getseqparcours() OWNER TO postgres;

--
-- Name: getseqpartages(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqpartages() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_partages')); 
END $$;


ALTER FUNCTION public.getseqpartages() OWNER TO postgres;

--
-- Name: getseqpays(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqpays() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqpays')); END $$;


ALTER FUNCTION public.getseqpays() OWNER TO postgres;

--
-- Name: getseqpoint(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqpoint() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQPOINT'));
END
$$;


ALTER FUNCTION public.getseqpoint() OWNER TO postgres;

--
-- Name: getseqpostemploi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqpostemploi() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_post_emploi')); 
END $$;


ALTER FUNCTION public.getseqpostemploi() OWNER TO postgres;

--
-- Name: getseqpostfichiers(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqpostfichiers() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_post_fichiers')); 
END $$;


ALTER FUNCTION public.getseqpostfichiers() OWNER TO postgres;

--
-- Name: getseqposts(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqposts() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_posts')); 
END $$;


ALTER FUNCTION public.getseqposts() OWNER TO postgres;

--
-- Name: getseqpoststage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqpoststage() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_post_stage')); 
END $$;


ALTER FUNCTION public.getseqpoststage() OWNER TO postgres;

--
-- Name: getseqposttopics(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqposttopics() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_post_topics')); 
END $$;


ALTER FUNCTION public.getseqposttopics() OWNER TO postgres;

--
-- Name: getseqprevision(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqprevision() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQPREVISION'));
END
$$;


ALTER FUNCTION public.getseqprevision() OWNER TO postgres;

--
-- Name: getseqproequipe(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqproequipe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqprojetequipe'));
END;
$$;


ALTER FUNCTION public.getseqproequipe() OWNER TO postgres;

--
-- Name: getseqpromesse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqpromesse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqpromesse'));
END
$$;


ALTER FUNCTION public.getseqpromesse() OWNER TO postgres;

--
-- Name: getseqpromotion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqpromotion() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqpromotion')); END $$;


ALTER FUNCTION public.getseqpromotion() OWNER TO postgres;

--
-- Name: getseqrepartition(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqrepartition() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqrep'));
END
$$;


ALTER FUNCTION public.getseqrepartition() OWNER TO postgres;

--
-- Name: getseqrepartitiondet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqrepartitiondet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqrepd'));
END
$$;


ALTER FUNCTION public.getseqrepartitiondet() OWNER TO postgres;

--
-- Name: getseqreportcaisse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqreportcaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqreportcaisse'));
END
$$;


ALTER FUNCTION public.getseqreportcaisse() OWNER TO postgres;

--
-- Name: getseqrequeteaenvoyer(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqrequeteaenvoyer() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_REQUETEAENVOYER'));
        END
    $$;


ALTER FUNCTION public.getseqrequeteaenvoyer() OWNER TO postgres;

--
-- Name: getseqreseauutilisateur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqreseauutilisateur() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqreseauutilisateur')); END $$;


ALTER FUNCTION public.getseqreseauutilisateur() OWNER TO postgres;

--
-- Name: getseqreseauxsociaux(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqreseauxsociaux() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqreseauxsociaux')); END $$;


ALTER FUNCTION public.getseqreseauxsociaux() OWNER TO postgres;

--
-- Name: getseqrestriction(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqrestriction() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqrestriction')); END $$;


ALTER FUNCTION public.getseqrestriction() OWNER TO postgres;

--
-- Name: getseqrolegroupe(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqrolegroupe() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_role_groupe')); 
END $$;


ALTER FUNCTION public.getseqrolegroupe() OWNER TO postgres;

--
-- Name: getseqsignalements(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqsignalements() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_signalements')); 
END $$;


ALTER FUNCTION public.getseqsignalements() OWNER TO postgres;

--
-- Name: getseqsource(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqsource() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqsource'));
END
$$;


ALTER FUNCTION public.getseqsource() OWNER TO postgres;

--
-- Name: getseqspecialite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqspecialite() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqspecialite')); END $$;


ALTER FUNCTION public.getseqspecialite() OWNER TO postgres;

--
-- Name: getseqstatutpublication(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqstatutpublication() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN 'STAT' || LPAD(nextval('seq_statut_publication')::TEXT, 5, '0');
END;
$$;


ALTER FUNCTION public.getseqstatutpublication() OWNER TO postgres;

--
-- Name: getseqstatutsignalement(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqstatutsignalement() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_statut_signalement')); 
END $$;


ALTER FUNCTION public.getseqstatutsignalement() OWNER TO postgres;

--
-- Name: getseqtache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('SeqTache'));
END;
$$;


ALTER FUNCTION public.getseqtache() OWNER TO postgres;

--
-- Name: getseqtauxavancementmodule(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtauxavancementmodule() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqTauxAvancementModule'));
END
    $$;


ALTER FUNCTION public.getseqtauxavancementmodule() OWNER TO postgres;

--
-- Name: getseqtauxavancementprojet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtauxavancementprojet() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqTauxAvancementProjet'));
END
    $$;


ALTER FUNCTION public.getseqtauxavancementprojet() OWNER TO postgres;

--
-- Name: getseqtauxdechange(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtauxdechange() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seqtauxdechange'));
END
$$;


ALTER FUNCTION public.getseqtauxdechange() OWNER TO postgres;

--
-- Name: getseqtopics(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtopics() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_topics')); 
END $$;


ALTER FUNCTION public.getseqtopics() OWNER TO postgres;

--
-- Name: getseqtype(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtype() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT nextval('SeqType'));
END;
$$;


ALTER FUNCTION public.getseqtype() OWNER TO postgres;

--
-- Name: getseqtypeabsence(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypeabsence() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqtypeabsence'));
END
$$;


ALTER FUNCTION public.getseqtypeabsence() OWNER TO postgres;

--
-- Name: getseqtypeaction(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypeaction() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqtypeaction'));
END
$$;


ALTER FUNCTION public.getseqtypeaction() OWNER TO postgres;

--
-- Name: getseqtypeactionmetier(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypeactionmetier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('seq_typeactionmetier'));
END
$$;


ALTER FUNCTION public.getseqtypeactionmetier() OWNER TO postgres;

--
-- Name: getseqtypebase(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypebase() RETURNS integer
    LANGUAGE plpgsql
    AS $$    
BEGIN
RETURN (SELECT nextval('seqtypebase'));	
END
$$;


ALTER FUNCTION public.getseqtypebase() OWNER TO postgres;

--
-- Name: getseqtypecaisse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypecaisse() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQTYPECAISSE'));
END
$$;


ALTER FUNCTION public.getseqtypecaisse() OWNER TO postgres;

--
-- Name: getseqtypeemploie(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypeemploie() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqtypeemploie')); END $$;


ALTER FUNCTION public.getseqtypeemploie() OWNER TO postgres;

--
-- Name: getseqtypefichier(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypefichier() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN 'TFIC' || LPAD(nextval('seq_type_fichier')::TEXT, 5, '0');
END;
$$;


ALTER FUNCTION public.getseqtypefichier() OWNER TO postgres;

--
-- Name: getseqtypemetier(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypemetier() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqtypemetier'));
 END
 $$;


ALTER FUNCTION public.getseqtypemetier() OWNER TO postgres;

--
-- Name: getseqtypenotification(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypenotification() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_type_notification')); 
END $$;


ALTER FUNCTION public.getseqtypenotification() OWNER TO postgres;

--
-- Name: getseqtypepage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypepage() RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
 RETURN (SELECT nextval('seqtypepage'));
 END
 $$;


ALTER FUNCTION public.getseqtypepage() OWNER TO postgres;

--
-- Name: getseqtypepublication(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypepublication() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN 'TYP' || LPAD(nextval('seq_type_publication')::TEXT, 5, '0');
END;
$$;


ALTER FUNCTION public.getseqtypepublication() OWNER TO postgres;

--
-- Name: getseqtyperepos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtyperepos() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN (SELECT nextval('seqtyperepos'));
END
$$;


ALTER FUNCTION public.getseqtyperepos() OWNER TO postgres;

--
-- Name: getseqtypetache(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypetache() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seq_typetache'));
        END
    $$;


ALTER FUNCTION public.getseqtypetache() OWNER TO postgres;

--
-- Name: getseqtypeutilisateur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqtypeutilisateur() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqtypeutilisateur')); END $$;


ALTER FUNCTION public.getseqtypeutilisateur() OWNER TO postgres;

--
-- Name: getsequdonation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsequdonation() RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN (SELECT nextval('seqdonation'));
        END
    $$;


ALTER FUNCTION public.getsequdonation() OWNER TO postgres;

--
-- Name: getsequnite(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsequnite() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQUNITE'));
END
$$;


ALTER FUNCTION public.getsequnite() OWNER TO postgres;

--
-- Name: getsequserequipe(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsequserequipe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('sequserequipe'));
END;
$$;


ALTER FUNCTION public.getsequserequipe() OWNER TO postgres;

--
-- Name: getsequserhomepage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsequserhomepage() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('sequserhomepage')); END $$;


ALTER FUNCTION public.getsequserhomepage() OWNER TO postgres;

--
-- Name: getsequsermenu(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsequsermenu() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('sequsermenu')); END $$;


ALTER FUNCTION public.getsequsermenu() OWNER TO postgres;

--
-- Name: getsequtilisateur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsequtilisateur() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('sequtilisateur')); END $$;


ALTER FUNCTION public.getsequtilisateur() OWNER TO postgres;

--
-- Name: getsequtilisateurinterets(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsequtilisateurinterets() RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_utilisateur_interets')); 
END $$;


ALTER FUNCTION public.getsequtilisateurinterets() OWNER TO postgres;

--
-- Name: getseqvente(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqvente() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQVENTE'));
END
$$;


ALTER FUNCTION public.getseqvente() OWNER TO postgres;

--
-- Name: getseqventedetails(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqventedetails() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQVENTEDETAILS'));
END
$$;


ALTER FUNCTION public.getseqventedetails() OWNER TO postgres;

--
-- Name: getseqville(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqville() RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN (SELECT nextval('seqville')); END $$;


ALTER FUNCTION public.getseqville() OWNER TO postgres;

--
-- Name: getseqvisibilitepublication(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqvisibilitepublication() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN 'VISI' || LPAD(nextval('seq_visibilite_publication')::TEXT, 5, '0');
END;
$$;


ALTER FUNCTION public.getseqvisibilitepublication() OWNER TO postgres;

--
-- Name: gettypeattributclasse(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gettypeattributclasse() RETURNS integer
    LANGUAGE sql
    AS $$
SELECT nextval('seq_typeattributclasse')::integer;
$$;


ALTER FUNCTION public.gettypeattributclasse() OWNER TO postgres;

--
-- Name: gettypefournisseur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gettypefournisseur() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT nextval('SEQTYPEFOURNISSEUR'));
END
$$;


ALTER FUNCTION public.gettypefournisseur() OWNER TO postgres;

--
-- Name: handle_commentaire_suppression(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_commentaire_suppression() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.supprime = 1 AND OLD.supprime = 0 THEN
        UPDATE posts SET nb_commentaires = nb_commentaires - 1 WHERE id = NEW.post_id;
    ELSIF NEW.supprime = 0 AND OLD.supprime = 1 THEN
        UPDATE posts SET nb_commentaires = nb_commentaires + 1 WHERE id = NEW.post_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.handle_commentaire_suppression() OWNER TO postgres;

--
-- Name: increment_commentaires(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.increment_commentaires() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.supprime = 0 THEN
        UPDATE posts SET nb_commentaires = nb_commentaires + 1 WHERE id = NEW.post_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.increment_commentaires() OWNER TO postgres;

--
-- Name: increment_likes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.increment_likes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE posts SET nb_likes = nb_likes + 1 WHERE id = NEW.post_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.increment_likes() OWNER TO postgres;

--
-- Name: increment_partages(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.increment_partages() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE posts SET nb_partages = nb_partages + 1 WHERE id = NEW.post_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.increment_partages() OWNER TO postgres;

--
-- Name: init_places_restantes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.init_places_restantes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.places_restantes IS NULL AND NEW.nombre_places IS NOT NULL THEN
        NEW.places_restantes := NEW.nombre_places;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.init_places_restantes() OWNER TO postgres;

--
-- Name: isferie(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.isferie(daty_ date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	declare rep varchar;
begin
	select valeur into rep from jourreposferie where valeur = daty_::varchar and daty<=daty_;
	if rep is null	then
		return 0;
	end if;
	return 1;
end;
$$;


ALTER FUNCTION public.isferie(daty_ date) OWNER TO postgres;

--
-- Name: isferieweekend(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.isferieweekend(daty_ date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	declare rep varchar;
begin
	select max(id) into rep from "jourreposweekend" c where daty in (
															select max(daty) from jourreposweekend where daty<=daty_ and valeur = extract(isodow from daty_)::varchar) and valeur = extract(isodow from daty_)::varchar;
	if rep is null	then
		return 0;
	end if;
	return 1;
end;
$$;


ALTER FUNCTION public.isferieweekend(daty_ date) OWNER TO postgres;

--
-- Name: isjourferie(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.isjourferie(daty_ date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
	if isFerie(daty_) = 1 then
		return 1;
	end if;
	if isFerieWeekEnd(daty_) = 1 then
		return 1;
	end if;
	return 0;
end;
$$;


ALTER FUNCTION public.isjourferie(daty_ date) OWNER TO postgres;

--
-- Name: make_identite_devis(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.make_identite_devis(p_iddevis character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_annee        TEXT;
    v_numero       TEXT;
    v_categorie    TEXT;
    v_client       TEXT;
    v_localisation TEXT;
    v_result       TEXT;
BEGIN
    SELECT
        TO_CHAR(d.daty, 'YYYY'),
        d.iddevis,
        cat.val,
        cl.nom,
        cp.localisation
    INTO
        v_annee,
        v_numero,
        v_categorie,
        v_client,
        v_localisation
    FROM devis d
             JOIN creation_projet cp ON d.idcreationprojet = cp.id
             LEFT JOIN categorie cat ON cp.categorie = cat.id
             LEFT JOIN client cl ON cp.client = cl.id
    WHERE d.iddevis = p_idDevis;

    v_result :=
            COALESCE(v_annee, '???') || '_' ||
            COALESCE(v_numero, '???') || '_' ||
            COALESCE(v_categorie, '???') || '_' ||
            COALESCE(v_client, '???') || '_' ||
            COALESCE(v_localisation, '???') || '_Devis';

    RETURN v_result;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Aucune donnée pour ce devis';
    WHEN OTHERS THEN
        RETURN 'Erreur: ' || SQLERRM;
END;
$$;


ALTER FUNCTION public.make_identite_devis(p_iddevis character varying) OWNER TO postgres;

--
-- Name: make_identite_projet(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.make_identite_projet(p_idcreationprojet character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
v_annee        TEXT;
    v_numero       TEXT;
    v_categorie    TEXT;
    v_client       TEXT;
    v_localisation TEXT;
    v_result       TEXT;
BEGIN
SELECT
    TO_CHAR(cp.debut, 'YYYY'),
    cp.id,
    cat.val,
    cl.nom,
    cp.localisation
INTO
    v_annee,
    v_numero,
    v_categorie,
    v_client,
    v_localisation
FROM
    creation_projet cp
        LEFT JOIN categorie cat ON cp.categorie = cat.id
        LEFT JOIN client cl ON cp.client = cl.id
WHERE cp.id = p_idCreationProjet;

v_result :=
            COALESCE(v_annee, '???') || '_' ||
            COALESCE(v_numero, '???') || '_' ||
            COALESCE(v_categorie, '???') || '_' ||
            COALESCE(v_client, '???') || '_' ||
            COALESCE(v_localisation, '???');

RETURN v_result;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Aucune donnée pour ce devis';
WHEN OTHERS THEN
        RETURN 'Erreur: ' || SQLERRM;
END;
$$;


ALTER FUNCTION public.make_identite_projet(p_idcreationprojet character varying) OWNER TO postgres;

--
-- Name: metierdependance(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.metierdependance(idmetier character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar; test varchar;
 begin
	 select string_agg(idfille, ',') into tmp
	 from metierrelation
	 where idmere = any (string_to_array(idmetier, ','));
	 if tmp is null then
		 return rep;
	 else
		select string_agg(unnest,',') into test from unnest(string_to_array(tmp, ','))
		where unnest = any (string_to_array(rep, ','));
		if test is not null then
			return rep;
		end if;
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return metierdependance(tmp, rep);
	 end if;
 end;
 $$;


ALTER FUNCTION public.metierdependance(idmetier character varying, rep character varying) OWNER TO postgres;

--
-- Name: metierdependancecomplet(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.metierdependancecomplet(idmetier character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare rep varchar; metierdependance varchar; metiermere varchar; metiermeredep varchar;
 begin
	 metiermere = metiermere(idmetier, null);
	if metiermere is not null and metiermere != '' then
		rep = metiermere;
	end if;

	metierdependance = metierdependance(idmetier, null);
	if metierdependance is not null and metierdependance != '' then
		if rep is not null then
			rep = rep || ',' || metierdependance;
		else rep = metierdependance;
		end if;
		metiermeredep = metiermere(metierdependance, null);
		if metiermeredep is not null and metiermeredep != '' then
			rep = rep || ',' || metiermeredep;
		end if;
	end if;
	return rep;
 end;
 $$;


ALTER FUNCTION public.metierdependancecomplet(idmetier character varying) OWNER TO postgres;

--
-- Name: metierdependante(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.metierdependante(idmetier character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar; test varchar;
 begin
	 select string_agg(idmere, ',') into tmp
	 from metierrelationlib
	 where idfille = any (string_to_array(idmetier, ','));
	 if tmp is null then
		 return rep;
	 else
		select string_agg(unnest,',') into test from unnest(string_to_array(tmp, ','))
		where unnest = any (string_to_array(rep, ','));
		if test is not null then
			return rep;
		end if;
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return metierdependante(tmp, rep);
	 end if;
 end;
 $$;


ALTER FUNCTION public.metierdependante(idmetier character varying, rep character varying) OWNER TO postgres;

--
-- Name: metierdependantecomplet(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.metierdependantecomplet(idmetier character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare rep varchar; metierdependante varchar; metierfille varchar;
 begin
	 metierdependante = metierdependante(idmetier, null);
	if metierdependante is not null and metierdependante != '' then
		rep = metierdependante;
		idmetier = idmetier || ',' || metierdependante;
	end if;

	metierfille = metierfille(idmetier, null);
	if metierfille is not null and metierfille != '' then
		if rep is not null then
			rep = rep || ',' || metierfille;
		else rep = metierfille;
		end if;
	end if;
	return rep;
 end;
 $$;


ALTER FUNCTION public.metierdependantecomplet(idmetier character varying) OWNER TO postgres;

--
-- Name: metierfille(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.metierfille(idmetier character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar;
 begin
	 select string_agg(id, ',') into tmp
	 from metierlib
	 where idmere = any (string_to_array(idmetier, ','));
	 if tmp is null then
		 return rep;
	 else
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return metierfille(tmp, rep);
	 end if;
 end;
 $$;


ALTER FUNCTION public.metierfille(idmetier character varying, rep character varying) OWNER TO postgres;

--
-- Name: metiermere(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.metiermere(idmetier character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar;
 begin
	 select string_agg(idmere, ',') into tmp
	 from metier
	 where id = any (string_to_array(idmetier, ','));
	 if tmp is null then
		 return rep;
	 else
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return metiermere(tmp, rep);
	 end if;
 end;
 $$;


ALTER FUNCTION public.metiermere(idmetier character varying, rep character varying) OWNER TO postgres;

--
-- Name: nombreutilisateur(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.nombreutilisateur(role character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare rep int;
begin
	select count(refuser) into rep from utilisateur where idrole = role;
	return rep;
end;
$$;


ALTER FUNCTION public.nombreutilisateur(role character varying) OWNER TO postgres;

--
-- Name: pagedependance(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.pagedependance(idpage character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar; test varchar;
 begin
	 select string_agg(idfille, ',') into tmp
	 from pagerelation
	 where idmere = any (string_to_array(idpage, ','));
	 if tmp is null then
		 return rep;
	 else
		select string_agg(unnest,',') into test from unnest(string_to_array(tmp, ','))
		where unnest = any (string_to_array(rep, ','));
		if test is not null then
			return rep;
		end if;

		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return pagedependance(tmp, rep);
	 end if;
 end;
 $$;


ALTER FUNCTION public.pagedependance(idpage character varying, rep character varying) OWNER TO postgres;

--
-- Name: pagedependante(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.pagedependante(idpage character varying, rep character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
 declare tmp varchar; test varchar;
 begin
	 select string_agg(idmere, ',') into tmp
	 from pagerelation
	 where idfille = any (string_to_array(idpage, ','));
	 if tmp is null then
		 return rep;
	 else
		select string_agg(unnest,',') into test from unnest(string_to_array(tmp, ','))
		where unnest = any (string_to_array(rep, ','));
		if test is not null then
			return rep;
		end if;
		 if rep is null then
			 rep = tmp;
		 else rep = rep||','||tmp;
		 end if;
		 return pagedependante(tmp, rep);
	 end if;
 end;
 $$;


ALTER FUNCTION public.pagedependante(idpage character varying, rep character varying) OWNER TO postgres;

--
-- Name: propositionestimation(character varying, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.propositionestimation(cote_ character varying, type_ character varying, niveau_ integer, responsable_ character varying) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
declare tempspasse_ float8;
begin
		select tempspasse into tempspasse_
		from moyenneTempsTacheResponsable
		where cote = cote_ and type = type_ and niveau = niveau_ and responsable = responsable_;

		if tempspasse_ is null then
			select tempspasse into tempspasse_
			from moyenneTempsTacheDefaut
			where cote = cote_ and type = type_ and niveau = niveau_;
		end if;

		if tempspasse_ is null then
			if niveau_>=0 then
				return propositionEstimation(cote_, type_, (niveau_ - 1), responsable_) + (30::numeric/60::numeric);
			end if;
			return (10::numeric/60::numeric);
		elsif tempspasse_ < (3::numeric/60::numeric) then
			return (3::numeric/60::numeric);
		else return tempspasse_;
		end if;
end;
$$;


ALTER FUNCTION public.propositionestimation(cote_ character varying, type_ character varying, niveau_ integer, responsable_ character varying) OWNER TO postgres;

--
-- Name: propositionestimation(character varying, character varying, integer, character varying, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.propositionestimation(cote_ character varying, type_ character varying, niveau_ integer, responsable_ character varying, datymin date, datymax date) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
declare tempspasse_ float8;
begin
		if datymin is null then
			datymin = '1940-01-01';
		end if;
		if datymax is null then
			datymax = now();
		end if;

		select avg(dureetachedouble) as tempspasse, cote, type, responsable, niveau into tempspasse_
		from tache_libcompletformat tl
		where etatfille != 80 and responsable is not null and responsable != ''
				and fin is not null and debut is not null
				and cote = cote_ and type = type_ and niveau = niveau_ and responsable = responsable_
				and daty>=datymin and daty<=datymax
		group by cote, type, responsable, niveau;


		if tempspasse_ is null then
			select  avg(dureetachedouble) as tempspasse, cote, type, niveau into tempspasse_
			from tache_libcompletformat tl
			where etatfille != 80 and responsable is not null and responsable != ''
				and fin is not null and debut is not null
				and cote = cote_ and type = type_ and niveau = niveau_
				and daty>=datymin and daty<=datymax
			group by cote, type, niveau;
		end if;

		if tempspasse_ is null then
			if niveau_>=0 then
				return propositionEstimation(cote_, type_, (niveau_ - 1), responsable_, datymin, datymax) + (30::numeric/60::numeric);
			end if;
			return (10::numeric/60::numeric);
		elsif tempspasse_ < (3::numeric/60::numeric) then
			return (3::numeric/60::numeric);
		else return tempspasse_;
		--else return round(tempspasse_::numeric, 0);
		end if;
end;
$$;


ALTER FUNCTION public.propositionestimation(cote_ character varying, type_ character varying, niveau_ integer, responsable_ character varying, datymin date, datymax date) OWNER TO postgres;

--
-- Name: set_idattribut_self(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_idattribut_self() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.idattribut = 'no_id' THEN
        NEW.idattribut := NEW.id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_idattribut_self() OWNER TO postgres;

--
-- Name: set_idliaison_relation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_idliaison_relation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.idliaison = 'no_id' THEN
        NEW.idliaison := NEW.idrelation;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_idliaison_relation() OWNER TO postgres;

--
-- Name: set_idmere_self(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_idmere_self() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.idmere = 'no_id' THEN
        NEW.idmere := NEW.id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_idmere_self() OWNER TO postgres;

--
-- Name: set_null_if_zero_edited_by(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_null_if_zero_edited_by() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.edited_by = 0 THEN
        NEW.edited_by := NULL;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_null_if_zero_edited_by() OWNER TO postgres;

--
-- Name: tachedependance(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.tachedependance(idtache_ character varying) RETURNS TABLE(id character varying)
    LANGUAGE plpgsql
    AS $$
declare r record;
begin
	for r in(select idtache, idmere, idfille
	from actionTacheLibvalide
	where (idtype = 'CREER' or idtype='MODIF') and idtache!=idtache_ and ((idmere in(
	select unnest(
			case
				when idtype = 'USAGE' then array[idmere::varchar, idfille::varchar]
				else
					case
						when (idmere is not null and idmere != '') and (idfille is not null and idfille != '') then array[idfille::varchar]
						when (idmere is null or (idmere is not null and idmere = '')) and (idfille is not null and idfille != '') then array[idfille::varchar]
						when (idfille is null or (idfille is not null and idfille = '')) and (idmere is not null and idmere != '') then array[idmere::varchar]
					end
			end
			)
	from actionTacheLibvalide
	where idtache = idtache_)) or ((idmere = '' or idmere is null) and idfille in(
	select unnest(
			case
				when idtype = 'USAGE' then array[idmere::varchar, idfille::varchar]
				else
					case
						when (idmere is not null and idmere != '') and (idfille is not null and idfille != '') then array[idfille::varchar]
						when (idmere is null or (idmere is not null and idmere = '')) and (idfille is not null and idfille != '') then array[idfille::varchar]
						when (idfille is null or (idfille is not null and idfille = '')) and (idmere is not null and idmere != '') then array[idmere::varchar]
					end
			end
			)
	from actionTacheLibvalide
	where idtache = idtache_)))) loop
									id:=r.idtache;
									return next;
								end loop;
end;
$$;


ALTER FUNCTION public.tachedependance(idtache_ character varying) OWNER TO postgres;

--
-- Name: v_allocation_charges_all(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.v_allocation_charges_all(date_debut date, date_fin date) RETURNS TABLE(idutilisateur character varying, nomutilisateur character varying, idtypeutilisateur character varying, typeutilisateur character varying, nombretache integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT
            u.refuser::VARCHAR AS idutilisateur,
            u.nomuser AS nomutilisateur,
            u.idtypeutilisateur,
            tu.val AS typeutilisateur,
            COUNT(t.id)::INTEGER AS nombretache
        FROM
            tache t
                JOIN utilisateur u ON t.responsable::TEXT = u.refuser::VARCHAR::TEXT
                LEFT JOIN type_utilisateur tu ON u.idtypeutilisateur::TEXT = tu.id::TEXT
                LEFT JOIN tachemere tm ON t.idmere::TEXT = tm.id::TEXT
                LEFT JOIN creation_projet cp ON tm.projet::TEXT = cp.id::TEXT
                AND (
                    (date_debut IS NULL AND date_fin IS NULL)
                        OR (
                        (date_debut IS NOT NULL AND date_fin IS NOT NULL) AND (
                            (cp.debut BETWEEN date_debut AND date_fin)
                                OR (cp.fin BETWEEN date_debut AND date_fin)
                                OR (cp.debut <= date_debut AND cp.fin >= date_fin)
                                OR (cp.debut IS NULL AND cp.fin IS NULL)
                            )
                        )
                    )
        GROUP BY u.refuser, u.nomuser, u.idtypeutilisateur, tu.val
        ORDER BY COUNT(t.id) DESC
        LIMIT 10;
END;
$$;


ALTER FUNCTION public.v_allocation_charges_all(date_debut date, date_fin date) OWNER TO postgres;

--
-- Name: v_phase_projets(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.v_phase_projets(date_debut date, date_fin date) RETURNS TABLE(idphase character varying, nomphase character varying, nbprojet integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT
            ph.id AS idphase,
            ph.val AS nomphase,
            COUNT(p.id)::INTEGER AS nbprojet
        FROM
            phase ph
                LEFT JOIN creation_projet p
                          ON p.phase::TEXT = ph.id::TEXT
                              AND (
                                 -- Si les deux dates sont null, on prend tout
                                 (date_debut IS NULL AND date_fin IS NULL)

                                     -- Sinon, on applique les conditions de chevauchement
                                     OR (
                                     (date_debut IS NOT NULL AND date_fin IS NOT NULL) AND (
                                         (p.debut BETWEEN date_debut AND date_fin)
                                             OR (p.fin BETWEEN date_debut AND date_fin)
                                             OR (p.debut <= date_debut AND p.fin >= date_fin)
                                             OR (p.debut IS NULL AND p.fin IS NULL)
                                         )
                                     )
                                 )
        GROUP BY ph.id, ph.val
        ORDER BY ph.id;
END;
$$;


ALTER FUNCTION public.v_phase_projets(date_debut date, date_fin date) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: action; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.action (
    id character varying(100) NOT NULL,
    idmere character varying(500),
    idfille character varying(500),
    idtype character varying(100)
);


ALTER TABLE public.action OWNER TO postgres;

--
-- Name: annulationutilisateur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.annulationutilisateur (
    idannulationuser character varying(30) NOT NULL,
    refuser character varying(30) DEFAULT ''::character varying,
    daty date DEFAULT CURRENT_DATE
);


ALTER TABLE public.annulationutilisateur OWNER TO postgres;

--
-- Name: calendrier_scolaire; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calendrier_scolaire (
    id character varying(10) NOT NULL,
    titre character varying(200) NOT NULL,
    description text,
    date_debut date NOT NULL,
    date_fin date,
    heure_debut character varying(10),
    heure_fin character varying(10),
    couleur character varying(20) DEFAULT '#0095DA'::character varying,
    idpromotion character varying(10),
    created_by integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.calendrier_scolaire OWNER TO postgres;

--
-- Name: promotion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion (
    id character varying(30) NOT NULL,
    libelle character varying(100) NOT NULL,
    annee integer NOT NULL,
    id_option character varying(30)
);


ALTER TABLE public.promotion OWNER TO postgres;

--
-- Name: calendrier_scolaire_cpl; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.calendrier_scolaire_cpl AS
 SELECT c.id,
    c.titre,
    c.description,
    c.date_debut,
    c.date_fin,
    c.heure_debut,
    c.heure_fin,
    c.couleur,
    c.idpromotion,
    c.created_by,
    c.created_at,
        CASE
            WHEN (p.libelle IS NOT NULL) THEN ((((p.libelle)::text || ' ('::text) || p.annee) || ')'::text)
            ELSE 'Tous'::text
        END AS libpromotion
   FROM (public.calendrier_scolaire c
     LEFT JOIN public.promotion p ON (((c.idpromotion)::text = (p.id)::text)));


ALTER VIEW public.calendrier_scolaire_cpl OWNER TO postgres;

--
-- Name: categorie_activite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categorie_activite (
    id character varying(50) NOT NULL,
    libelle character varying(200) NOT NULL
);


ALTER TABLE public.categorie_activite OWNER TO postgres;

--
-- Name: commentaires; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commentaires (
    id character varying(50) NOT NULL,
    idutilisateur integer NOT NULL,
    post_id character varying(50) NOT NULL,
    parent_id character varying(50),
    contenu text NOT NULL,
    supprime integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    edited_at timestamp without time zone
);


ALTER TABLE public.commentaires OWNER TO postgres;

--
-- Name: TABLE commentaires; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.commentaires IS 'Commentaires avec support de réponses (parent_id)';


--
-- Name: competence; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.competence (
    id character varying(30) NOT NULL,
    libelle character varying(150) NOT NULL
);


ALTER TABLE public.competence OWNER TO postgres;

--
-- Name: competence_utilisateur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.competence_utilisateur (
    idcompetence character varying(30) NOT NULL,
    idutilisateur integer NOT NULL
);


ALTER TABLE public.competence_utilisateur OWNER TO postgres;

--
-- Name: diplome; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diplome (
    id character varying(30) NOT NULL,
    libelle character varying(150) NOT NULL
);


ALTER TABLE public.diplome OWNER TO postgres;

--
-- Name: direction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.direction (
    id character varying(30) NOT NULL,
    val character varying(255) DEFAULT ''::character varying
);


ALTER TABLE public.direction OWNER TO postgres;

--
-- Name: domaine; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.domaine (
    id character varying(30) NOT NULL,
    libelle character varying(150) NOT NULL,
    idpere character varying(30)
);


ALTER TABLE public.domaine OWNER TO postgres;

--
-- Name: ecole; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ecole (
    id character varying(30) NOT NULL,
    libelle character varying(150) NOT NULL
);


ALTER TABLE public.ecole OWNER TO postgres;

--
-- Name: emploi_competence; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.emploi_competence (
    post_id character varying(50) NOT NULL,
    idcompetence character varying(30) NOT NULL
);


ALTER TABLE public.emploi_competence OWNER TO postgres;

--
-- Name: TABLE emploi_competence; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.emploi_competence IS 'Association many-to-many entre offres d''emploi et compétences';


--
-- Name: COLUMN emploi_competence.post_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.emploi_competence.post_id IS 'FK vers post_emploi';


--
-- Name: COLUMN emploi_competence.idcompetence; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.emploi_competence.idcompetence IS 'FK vers competence';


--
-- Name: entreprise; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entreprise (
    id character varying(30) NOT NULL,
    libelle character varying(150) NOT NULL,
    idville character varying(30),
    description text
);


ALTER TABLE public.entreprise OWNER TO postgres;

--
-- Name: experience; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.experience (
    id character varying(30) NOT NULL,
    idutilisateur integer,
    datedebut date,
    datefin date,
    poste character varying(150),
    iddomaine character varying(30),
    identreprise character varying(30),
    idtypeemploie character varying(30)
);


ALTER TABLE public.experience OWNER TO postgres;

--
-- Name: generateurtable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.generateurtable (
    tablename character varying(100) NOT NULL
);


ALTER TABLE public.generateurtable OWNER TO postgres;

--
-- Name: TABLE generateurtable; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.generateurtable IS 'Table APJ - Liste des tables mappées pour le framework ORM';


--
-- Name: groupe_membres; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groupe_membres (
    id character varying(50) NOT NULL,
    idutilisateur integer NOT NULL,
    idgroupe character varying(50) NOT NULL,
    idrole character varying(50) NOT NULL,
    statut character varying(50) DEFAULT 'actif'::character varying,
    joined_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.groupe_membres OWNER TO postgres;

--
-- Name: TABLE groupe_membres; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.groupe_membres IS 'Membres des groupes avec rôles';


--
-- Name: groupes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groupes (
    id character varying(50) NOT NULL,
    nom character varying(200) NOT NULL,
    description text,
    photo_couverture character varying(500),
    photo_profil character varying(500),
    type_groupe character varying(50) DEFAULT 'ouvert'::character varying,
    created_by integer NOT NULL,
    actif integer DEFAULT 1,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    idpromotion character varying(30)
);


ALTER TABLE public.groupes OWNER TO postgres;

--
-- Name: TABLE groupes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.groupes IS 'Groupes d''utilisateurs (promotion, intérêts, etc.)';


--
-- Name: historique; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historique (
    idhistorique character varying(30) NOT NULL,
    datehistorique date DEFAULT CURRENT_DATE,
    heure character varying(20) DEFAULT ''::character varying,
    objet character varying(255) DEFAULT ''::character varying,
    action character varying(255) DEFAULT ''::character varying,
    idutilisateur character varying(30) DEFAULT ''::character varying,
    refobjet character varying(255) DEFAULT ''::character varying
);


ALTER TABLE public.historique OWNER TO postgres;

--
-- Name: historique_valeur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historique_valeur (
    id character varying(50) NOT NULL,
    idhisto character varying(255),
    refhisto character varying(50),
    nom_table character varying(50),
    nom_classe character varying(50),
    val1 character varying(255),
    val2 character varying(255),
    val3 character varying(255),
    val4 character varying(255),
    val5 character varying(255),
    val6 character varying(255),
    val7 character varying(255),
    val8 character varying(255),
    val9 character varying(255),
    val10 character varying(255),
    val11 character varying(255),
    val12 character varying(255),
    val13 character varying(255),
    val14 character varying(255),
    val15 character varying(255),
    val16 character varying(255),
    val17 character varying(255),
    val18 character varying(255),
    val19 character varying(255),
    val20 character varying(255),
    val21 character varying(255),
    val22 character varying(255),
    val23 character varying(255),
    val24 character varying(255),
    val25 character varying(255),
    val26 character varying(255),
    val27 character varying(255),
    val28 character varying(255),
    val29 character varying(255),
    val30 character varying(255),
    val31 character varying(255),
    val32 character varying(255),
    val33 character varying(255),
    val34 character varying(255),
    val35 character varying(255),
    val36 character varying(255),
    val37 character varying(255),
    val38 character varying(255),
    val39 character varying(255),
    val40 character varying(255)
);


ALTER TABLE public.historique_valeur OWNER TO postgres;

--
-- Name: likes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.likes (
    id character varying(50) NOT NULL,
    idutilisateur integer NOT NULL,
    post_id character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.likes OWNER TO postgres;

--
-- Name: TABLE likes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.likes IS 'Likes sur les publications';


--
-- Name: listecolonnetable; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.listecolonnetable AS
 SELECT table_catalog,
    upper((table_name)::text) AS table_name,
    column_name,
        CASE
            WHEN ((data_type)::text = 'character varying'::text) THEN 'character varying'::name
            WHEN ((data_type)::text = 'character'::text) THEN 'char'::name
            WHEN ((data_type)::text = 'text'::text) THEN 'character varying'::name
            WHEN ((data_type)::text = 'integer'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'smallint'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'bigint'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'numeric'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'double precision'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'real'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'date'::text) THEN 'Date'::name
            WHEN ((data_type)::text ~~ 'timestamp%'::text) THEN 'timestamp'::name
            WHEN ((data_type)::text = 'boolean'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'bytea'::text) THEN 'blob'::name
            WHEN ((data_type)::text = 'USER-DEFINED'::text) THEN (udt_name)::name
            ELSE (data_type)::name
        END AS data_type,
    is_nullable,
    column_default,
    ordinal_position AS column_id,
    COALESCE((character_maximum_length)::integer, (numeric_precision)::integer,
        CASE
            WHEN ((data_type)::text = 'integer'::text) THEN 9
            WHEN ((data_type)::text = 'smallint'::text) THEN 4
            WHEN ((data_type)::text = 'bigint'::text) THEN 18
            WHEN ((data_type)::text = 'boolean'::text) THEN 1
            WHEN ((data_type)::text = 'date'::text) THEN 10
            WHEN ((data_type)::text ~~ 'timestamp%'::text) THEN 26
            WHEN ((data_type)::text = 'text'::text) THEN 4000
            ELSE 0
        END) AS data_precision,
    COALESCE((numeric_scale)::integer, 0) AS data_scale
   FROM information_schema.columns c
  WHERE ((table_schema)::name = 'public'::name)
  ORDER BY c.table_name, ordinal_position;


ALTER VIEW public.listecolonnetable OWNER TO postgres;

--
-- Name: mailcc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mailcc (
    id character varying(100) NOT NULL,
    mail character varying(500)
);


ALTER TABLE public.mailcc OWNER TO postgres;

--
-- Name: menudynamique; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menudynamique (
    id character varying(50) NOT NULL,
    libelle character varying(50),
    icone character varying(250),
    href character varying(250),
    rang integer,
    niveau integer,
    id_pere character varying(50)
);


ALTER TABLE public.menudynamique OWNER TO postgres;

--
-- Name: moderation_utilisateur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.moderation_utilisateur (
    id character varying(30) NOT NULL,
    idutilisateur integer,
    idmoderateur integer,
    type_action character varying(20) NOT NULL,
    motif character varying(255),
    date_action timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    date_expiration date
);


ALTER TABLE public.moderation_utilisateur OWNER TO postgres;

--
-- Name: motif_signalement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.motif_signalement (
    id character varying(50) NOT NULL,
    libelle character varying(100) NOT NULL,
    code character varying(50) NOT NULL,
    icon character varying(50),
    couleur character varying(20),
    gravite integer,
    action_automatique character varying(100),
    description text,
    actif integer DEFAULT 1,
    ordre integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.motif_signalement OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id character varying(50) NOT NULL,
    idutilisateur integer NOT NULL,
    emetteur_id integer,
    idtypenotification character varying(50) NOT NULL,
    post_id character varying(50),
    commentaire_id character varying(50),
    groupe_id character varying(50),
    contenu text,
    lien character varying(500),
    vu integer DEFAULT 0,
    lu_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: TABLE notifications; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.notifications IS 'Notifications pour interactions (like, commentaire, etc.)';


--
-- Name: option; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.option (
    id character varying(30) NOT NULL,
    libelle character varying(50) NOT NULL
);


ALTER TABLE public.option OWNER TO postgres;

--
-- Name: paramcrypt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paramcrypt (
    id character varying(30) NOT NULL,
    niveau integer DEFAULT 5 NOT NULL,
    croissante integer DEFAULT 0 NOT NULL,
    idutilisateur character varying(30) NOT NULL
);


ALTER TABLE public.paramcrypt OWNER TO postgres;

--
-- Name: parcours; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parcours (
    id character varying(30) NOT NULL,
    datedebut date,
    datefin date,
    idutilisateur integer,
    iddiplome character varying(30),
    iddomaine character varying(30),
    idecole character varying(30)
);


ALTER TABLE public.parcours OWNER TO postgres;

--
-- Name: partages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.partages (
    id character varying(50) NOT NULL,
    idutilisateur integer NOT NULL,
    post_id character varying(50) NOT NULL,
    commentaire text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.partages OWNER TO postgres;

--
-- Name: TABLE partages; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.partages IS 'Partages de publications avec commentaire optionnel';


--
-- Name: pays; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pays (
    id character varying(30) NOT NULL,
    libelle character varying(100) NOT NULL
);


ALTER TABLE public.pays OWNER TO postgres;

--
-- Name: post_activite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_activite (
    post_id character varying(50) NOT NULL,
    titre character varying(200) NOT NULL,
    lieu character varying(200),
    adresse text,
    date_debut timestamp without time zone,
    date_fin timestamp without time zone,
    prix double precision,
    nombre_places integer,
    places_restantes integer,
    contact_email character varying(200),
    contact_tel character varying(50),
    lien_inscription character varying(500),
    lien_externe character varying(500),
    idcategorie character varying(50)
);


ALTER TABLE public.post_activite OWNER TO postgres;

--
-- Name: TABLE post_activite; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.post_activite IS 'Détails spécifiques pour les activités/événements';


--
-- Name: post_emploi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_emploi (
    post_id character varying(50) NOT NULL,
    entreprise character varying(200),
    localisation character varying(200),
    poste character varying(200) NOT NULL,
    type_contrat character varying(50),
    salaire_min numeric(10,2),
    salaire_max numeric(10,2),
    devise character varying(10) DEFAULT 'MGA'::character varying,
    experience_requise character varying(100),
    competences_requises text,
    niveau_etude_requis character varying(100),
    teletravail_possible integer DEFAULT 0,
    date_limite date,
    contact_email character varying(200),
    contact_tel character varying(50),
    lien_candidature character varying(500),
    identreprise character varying(30)
);


ALTER TABLE public.post_emploi OWNER TO postgres;

--
-- Name: TABLE post_emploi; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.post_emploi IS 'Détails spécifiques pour les offres d''emploi';


--
-- Name: post_fichiers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_fichiers (
    id character varying(50) NOT NULL,
    post_id character varying(50) NOT NULL,
    idtypefichier character varying(50) NOT NULL,
    nom_fichier character varying(200) NOT NULL,
    nom_original character varying(200) NOT NULL,
    chemin character varying(500) NOT NULL,
    taille_octets bigint,
    mime_type character varying(100),
    ordre integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.post_fichiers OWNER TO postgres;

--
-- Name: TABLE post_fichiers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.post_fichiers IS 'Fichiers joints aux publications (images, documents, etc.)';


--
-- Name: post_stage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_stage (
    post_id character varying(50) NOT NULL,
    entreprise character varying(200),
    localisation character varying(200),
    duree character varying(100),
    date_debut date,
    date_fin date,
    indemnite numeric(10,2),
    niveau_etude_requis character varying(100),
    competences_requises text,
    convention_requise integer DEFAULT 0,
    places_disponibles integer,
    contact_email character varying(200),
    contact_tel character varying(50),
    lien_candidature character varying(500),
    identreprise character varying(30)
);


ALTER TABLE public.post_stage OWNER TO postgres;

--
-- Name: TABLE post_stage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.post_stage IS 'Détails spécifiques pour les offres de stage';


--
-- Name: post_topics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_topics (
    id character varying(50) NOT NULL,
    post_id character varying(50) NOT NULL,
    topic_id character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.post_topics OWNER TO postgres;

--
-- Name: TABLE post_topics; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.post_topics IS 'Association publications <-> topics pour filtrage/recommandations';


--
-- Name: posts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.posts (
    id character varying(50) NOT NULL,
    idutilisateur integer NOT NULL,
    idgroupe character varying(50),
    idtypepublication character varying(50) NOT NULL,
    idstatutpublication character varying(50) NOT NULL,
    idvisibilite character varying(50) NOT NULL,
    contenu text NOT NULL,
    epingle integer DEFAULT 0,
    supprime integer DEFAULT 0,
    date_suppression timestamp without time zone,
    nb_likes integer DEFAULT 0,
    nb_commentaires integer DEFAULT 0,
    nb_partages integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    edited_at timestamp without time zone,
    edited_by integer
);


ALTER TABLE public.posts OWNER TO postgres;

--
-- Name: TABLE posts; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.posts IS 'Table principale des publications alumni';


--
-- Name: reseau_utilisateur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reseau_utilisateur (
    id character varying(30) NOT NULL,
    idreseauxsociaux character varying(30),
    idutilisateur integer,
    lien character varying(255)
);


ALTER TABLE public.reseau_utilisateur OWNER TO postgres;

--
-- Name: reseaux_sociaux; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reseaux_sociaux (
    id character varying(30) NOT NULL,
    libelle character varying(100) NOT NULL,
    icone character varying(255)
);


ALTER TABLE public.reseaux_sociaux OWNER TO postgres;

--
-- Name: restriction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.restriction (
    id character varying(100) NOT NULL,
    idrole character varying(100),
    idaction character varying(100),
    tablename character varying(100),
    autorisation character varying(100),
    description character varying(500),
    iddirection character varying(100)
);


ALTER TABLE public.restriction OWNER TO postgres;

--
-- Name: role_groupe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_groupe (
    id character varying(50) NOT NULL,
    libelle character varying(100) NOT NULL,
    code character varying(50) NOT NULL,
    icon character varying(50),
    couleur character varying(20),
    permissions text,
    niveau_acces integer,
    description text,
    actif integer DEFAULT 1,
    ordre integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.role_groupe OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    idrole character varying(30) NOT NULL,
    descrole character varying(100) NOT NULL,
    rang integer DEFAULT 0
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: seq_absence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_absence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_absence OWNER TO postgres;

--
-- Name: seq_actionprojet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_actionprojet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_actionprojet OWNER TO postgres;

--
-- Name: seq_alert; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_alert
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_alert OWNER TO postgres;

--
-- Name: seq_analyses; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_analyses
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_analyses OWNER TO postgres;

--
-- Name: seq_apjclasse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_apjclasse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_apjclasse OWNER TO postgres;

--
-- Name: seq_attribusentite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_attribusentite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_attribusentite OWNER TO postgres;

--
-- Name: seq_attributclasse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_attributclasse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_attributclasse OWNER TO postgres;

--
-- Name: seq_attributoracle; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_attributoracle
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_attributoracle OWNER TO postgres;

--
-- Name: seq_attributpostgres; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_attributpostgres
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_attributpostgres OWNER TO postgres;

--
-- Name: seq_attributtype; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_attributtype
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_attributtype OWNER TO postgres;

--
-- Name: seq_boutonchamp; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_boutonchamp
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_boutonchamp OWNER TO postgres;

--
-- Name: seq_boutonpage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_boutonpage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_boutonpage OWNER TO postgres;

--
-- Name: seq_branche; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_branche
    START WITH 10
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_branche OWNER TO postgres;

--
-- Name: seq_caisse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_caisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_caisse OWNER TO postgres;

--
-- Name: seq_calendrier_scolaire; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_calendrier_scolaire
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_calendrier_scolaire OWNER TO postgres;

--
-- Name: seq_categorie_activite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_categorie_activite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_categorie_activite OWNER TO postgres;

--
-- Name: seq_champdynamique; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_champdynamique
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_champdynamique OWNER TO postgres;

--
-- Name: seq_champsspeciaux; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_champsspeciaux
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_champsspeciaux OWNER TO postgres;

--
-- Name: seq_cheminprojetuser; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_cheminprojetuser
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_cheminprojetuser OWNER TO postgres;

--
-- Name: seq_classe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_classe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_classe OWNER TO postgres;

--
-- Name: seq_commentaires; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_commentaires
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_commentaires OWNER TO postgres;

--
-- Name: seq_comptaclassecompte; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptaclassecompte
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptaclassecompte OWNER TO postgres;

--
-- Name: seq_comptacompte; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptacompte
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptacompte OWNER TO postgres;

--
-- Name: seq_comptacomptebackup; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptacomptebackup
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptacomptebackup OWNER TO postgres;

--
-- Name: seq_comptaecriture; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptaecriture
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptaecriture OWNER TO postgres;

--
-- Name: seq_comptaecriturebackup; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptaecriturebackup
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptaecriturebackup OWNER TO postgres;

--
-- Name: seq_comptaexercice; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptaexercice
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptaexercice OWNER TO postgres;

--
-- Name: seq_comptajournal; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptajournal
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptajournal OWNER TO postgres;

--
-- Name: seq_comptajournalbackup; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptajournalbackup
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptajournalbackup OWNER TO postgres;

--
-- Name: seq_comptalettrage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptalettrage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptalettrage OWNER TO postgres;

--
-- Name: seq_comptaorigine; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptaorigine
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptaorigine OWNER TO postgres;

--
-- Name: seq_comptasousecriture; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptasousecriture
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptasousecriture OWNER TO postgres;

--
-- Name: seq_comptasousecriturebackup; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptasousecriturebackup
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptasousecriturebackup OWNER TO postgres;

--
-- Name: seq_comptatypecompte; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_comptatypecompte
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_comptatypecompte OWNER TO postgres;

--
-- Name: seq_conception_pm; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_conception_pm
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_conception_pm OWNER TO postgres;

--
-- Name: seq_connexion; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_connexion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_connexion OWNER TO postgres;

--
-- Name: seq_coutprevisionnel; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_coutprevisionnel
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_coutprevisionnel OWNER TO postgres;

--
-- Name: seq_deploiement; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_deploiement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_deploiement OWNER TO postgres;

--
-- Name: seq_devis; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_devis
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_devis OWNER TO postgres;

--
-- Name: seq_devisfille; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_devisfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_devisfille OWNER TO postgres;

--
-- Name: seq_diagramaffichage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramaffichage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramaffichage OWNER TO postgres;

--
-- Name: seq_diagramclass; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramclass
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramclass OWNER TO postgres;

--
-- Name: seq_diagramclasscomposant; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramclasscomposant
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramclasscomposant OWNER TO postgres;

--
-- Name: seq_diagramclasscomposanttype; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramclasscomposanttype
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramclasscomposanttype OWNER TO postgres;

--
-- Name: seq_diagramclasspackage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramclasspackage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramclasspackage OWNER TO postgres;

--
-- Name: seq_diagramcomposant; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramcomposant
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramcomposant OWNER TO postgres;

--
-- Name: seq_diagrampackage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagrampackage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagrampackage OWNER TO postgres;

--
-- Name: seq_diagramtable; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramtable
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramtable OWNER TO postgres;

--
-- Name: seq_diagramtablecolonne; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_diagramtablecolonne
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_diagramtablecolonne OWNER TO postgres;

--
-- Name: seq_donation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_donation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


ALTER SEQUENCE public.seq_donation OWNER TO postgres;

--
-- Name: seq_entitescript; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_entitescript
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_entitescript OWNER TO postgres;

--
-- Name: seq_entreprise; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_entreprise
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_entreprise OWNER TO postgres;

--
-- Name: seq_exceptiontache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_exceptiontache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_exceptiontache OWNER TO postgres;

--
-- Name: seq_groupe_membres; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_groupe_membres
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_groupe_membres OWNER TO postgres;

--
-- Name: seq_groupes; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_groupes
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_groupes OWNER TO postgres;

--
-- Name: seq_histoinsert; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_histoinsert
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_histoinsert OWNER TO postgres;

--
-- Name: seq_honoraire; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_honoraire
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_honoraire OWNER TO postgres;

--
-- Name: seq_indisponibilite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_indisponibilite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_indisponibilite OWNER TO postgres;

--
-- Name: seq_jourrepos; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_jourrepos
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_jourrepos OWNER TO postgres;

--
-- Name: seq_likes; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_likes
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_likes OWNER TO postgres;

--
-- Name: seq_magasin2; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_magasin2
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_magasin2 OWNER TO postgres;

--
-- Name: seq_mappingtypeattribut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_mappingtypeattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_mappingtypeattribut OWNER TO postgres;

--
-- Name: seq_metierfille; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_metierfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_metierfille OWNER TO postgres;

--
-- Name: seq_module; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_module
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_module OWNER TO postgres;

--
-- Name: seq_module_projet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_module_projet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_module_projet OWNER TO postgres;

--
-- Name: seq_motif_signalement; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_motif_signalement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_motif_signalement OWNER TO postgres;

--
-- Name: seq_niveauclient; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_niveauclient
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_niveauclient OWNER TO postgres;

--
-- Name: seq_notification; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_notification
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_notification OWNER TO postgres;

--
-- Name: seq_notificationdetails; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_notificationdetails
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_notificationdetails OWNER TO postgres;

--
-- Name: seq_notificationgroupe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_notificationgroupe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_notificationgroupe OWNER TO postgres;

--
-- Name: seq_notifications; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_notifications
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_notifications OWNER TO postgres;

--
-- Name: seq_notificationsignal; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_notificationsignal
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_notificationsignal OWNER TO postgres;

--
-- Name: seq_pageanalyse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pageanalyse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pageanalyse OWNER TO postgres;

--
-- Name: seq_pageanalyseattribut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pageanalyseattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pageanalyseattribut OWNER TO postgres;

--
-- Name: seq_pageattribut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pageattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pageattribut OWNER TO postgres;

--
-- Name: seq_pagefiche; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pagefiche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pagefiche OWNER TO postgres;

--
-- Name: seq_pageficheattribut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pageficheattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pageficheattribut OWNER TO postgres;

--
-- Name: seq_pageliste; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pageliste
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pageliste OWNER TO postgres;

--
-- Name: seq_pagelisteattribut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pagelisteattribut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pagelisteattribut OWNER TO postgres;

--
-- Name: seq_pagesaisie; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pagesaisie
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_pagesaisie OWNER TO postgres;

--
-- Name: seq_panalysechampfiltre; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_panalysechampfiltre
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_panalysechampfiltre OWNER TO postgres;

--
-- Name: seq_partages; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_partages
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_partages OWNER TO postgres;

--
-- Name: seq_pays; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pays
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_pays OWNER TO postgres;

--
-- Name: seq_phaseproject; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_phaseproject
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_phaseproject OWNER TO postgres;

--
-- Name: seq_plistchampfiltre; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_plistchampfiltre
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_plistchampfiltre OWNER TO postgres;

--
-- Name: seq_pointage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_pointage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_pointage OWNER TO postgres;

--
-- Name: seq_post_emploi; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_post_emploi
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_post_emploi OWNER TO postgres;

--
-- Name: seq_post_fichiers; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_post_fichiers
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_post_fichiers OWNER TO postgres;

--
-- Name: seq_post_stage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_post_stage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_post_stage OWNER TO postgres;

--
-- Name: seq_post_topics; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_post_topics
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_post_topics OWNER TO postgres;

--
-- Name: seq_posts; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_posts
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_posts OWNER TO postgres;

--
-- Name: seq_projetutilisateur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_projetutilisateur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_projetutilisateur OWNER TO postgres;

--
-- Name: seq_proposition; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_proposition
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_proposition OWNER TO postgres;

--
-- Name: seq_province; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_province
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_province OWNER TO postgres;

--
-- Name: seq_qualite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_qualite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_qualite OWNER TO postgres;

--
-- Name: seq_relation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_relation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_relation OWNER TO postgres;

--
-- Name: seq_requeteaenvoyer; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_requeteaenvoyer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_requeteaenvoyer OWNER TO postgres;

--
-- Name: seq_role_groupe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_role_groupe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_role_groupe OWNER TO postgres;

--
-- Name: seq_script; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_script
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_script OWNER TO postgres;

--
-- Name: seq_scriptversionning; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_scriptversionning
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_scriptversionning OWNER TO postgres;

--
-- Name: seq_serveur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_serveur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_serveur OWNER TO postgres;

--
-- Name: seq_signalements; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_signalements
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_signalements OWNER TO postgres;

--
-- Name: seq_statut_publication; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_statut_publication
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_statut_publication OWNER TO postgres;

--
-- Name: seq_statut_signalement; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_statut_signalement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_statut_signalement OWNER TO postgres;

--
-- Name: seq_tache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_tache
    START WITH 182
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_tache OWNER TO postgres;

--
-- Name: seq_tache_git_details; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_tache_git_details
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_tache_git_details OWNER TO postgres;

--
-- Name: seq_tache_git_mere; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_tache_git_mere
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_tache_git_mere OWNER TO postgres;

--
-- Name: seq_tauxhonoraire; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_tauxhonoraire
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_tauxhonoraire OWNER TO postgres;

--
-- Name: seq_tempstravail; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_tempstravail
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_tempstravail OWNER TO postgres;

--
-- Name: seq_timingapplication; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_timingapplication
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_timingapplication OWNER TO postgres;

--
-- Name: seq_timingsoustache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_timingsoustache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_timingsoustache OWNER TO postgres;

--
-- Name: seq_topics; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_topics
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_topics OWNER TO postgres;

--
-- Name: seq_type_fichier; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_type_fichier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_type_fichier OWNER TO postgres;

--
-- Name: seq_type_notification; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_type_notification
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_type_notification OWNER TO postgres;

--
-- Name: seq_type_publication; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_type_publication
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_type_publication OWNER TO postgres;

--
-- Name: seq_type_utilisateur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_type_utilisateur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_type_utilisateur OWNER TO postgres;

--
-- Name: seq_typeactionmetier; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typeactionmetier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_typeactionmetier OWNER TO postgres;

--
-- Name: seq_typeattributclasse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typeattributclasse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_typeattributclasse OWNER TO postgres;

--
-- Name: seq_typechampsspeciaux; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typechampsspeciaux
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typechampsspeciaux OWNER TO postgres;

--
-- Name: seq_typeclasse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typeclasse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_typeclasse OWNER TO postgres;

--
-- Name: seq_typedependancediagram; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typedependancediagram
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typedependancediagram OWNER TO postgres;

--
-- Name: seq_typedependanceobjet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typedependanceobjet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typedependanceobjet OWNER TO postgres;

--
-- Name: seq_typeliaison; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typeliaison
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_typeliaison OWNER TO postgres;

--
-- Name: seq_typemagasin; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typemagasin
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_typemagasin OWNER TO postgres;

--
-- Name: seq_typeouinon; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typeouinon
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typeouinon OWNER TO postgres;

--
-- Name: seq_typepageanalyse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typepageanalyse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typepageanalyse OWNER TO postgres;

--
-- Name: seq_typepageliste; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typepageliste
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typepageliste OWNER TO postgres;

--
-- Name: seq_typepagesaisie; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typepagesaisie
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typepagesaisie OWNER TO postgres;

--
-- Name: seq_typeplistchampfiltre; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typeplistchampfiltre
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seq_typeplistchampfiltre OWNER TO postgres;

--
-- Name: seq_typerelation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typerelation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_typerelation OWNER TO postgres;

--
-- Name: seq_typescript; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typescript
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_typescript OWNER TO postgres;

--
-- Name: seq_typetache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_typetache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_typetache OWNER TO postgres;

--
-- Name: seq_utilisateur_interets; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_utilisateur_interets
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_utilisateur_interets OWNER TO postgres;

--
-- Name: seq_v_classeetfiche; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_v_classeetfiche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_v_classeetfiche OWNER TO postgres;

--
-- Name: seq_v_classetfiche; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_v_classetfiche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seq_v_classetfiche OWNER TO postgres;

--
-- Name: seq_visibilite_publication; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_visibilite_publication
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_visibilite_publication OWNER TO postgres;

--
-- Name: seqaction; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqaction
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqaction OWNER TO postgres;

--
-- Name: seqactiontache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqactiontache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqactiontache OWNER TO postgres;

--
-- Name: seqannulationutilisateur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqannulationutilisateur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqannulationutilisateur OWNER TO postgres;

--
-- Name: seqarchitecture; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqarchitecture
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqarchitecture OWNER TO postgres;

--
-- Name: seqattacher_fichier; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqattacher_fichier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqattacher_fichier OWNER TO postgres;

--
-- Name: seqavoirfc; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqavoirfc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqavoirfc OWNER TO postgres;

--
-- Name: seqavoirfcfille; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqavoirfcfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqavoirfcfille OWNER TO postgres;

--
-- Name: seqbase; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqbase
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqbase OWNER TO postgres;

--
-- Name: seqbaserelation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqbaserelation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqbaserelation OWNER TO postgres;

--
-- Name: seqbranche; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqbranche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqbranche OWNER TO postgres;

--
-- Name: seqcaisse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqcaisse OWNER TO postgres;

--
-- Name: seqcanevatache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcanevatache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqcanevatache OWNER TO postgres;

--
-- Name: seqcateging; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcateging
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqcateging OWNER TO postgres;

--
-- Name: seqcategorie; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcategorie
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqcategorie OWNER TO postgres;

--
-- Name: seqcategorieavoirfc; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcategorieavoirfc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqcategorieavoirfc OWNER TO postgres;

--
-- Name: seqcategoriecaisse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcategoriecaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqcategoriecaisse OWNER TO postgres;

--
-- Name: seqcategorieniveau; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcategorieniveau
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqcategorieniveau OWNER TO postgres;

--
-- Name: seqclient; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqclient
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqclient OWNER TO postgres;

--
-- Name: seqcompetence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcompetence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqcompetence OWNER TO postgres;

--
-- Name: seqcote; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcote
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqcote OWNER TO postgres;

--
-- Name: seqcrcontent; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcrcontent
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqcrcontent OWNER TO postgres;

--
-- Name: seqcrcontentfille; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcrcontentfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqcrcontentfille OWNER TO postgres;

--
-- Name: seqcreation_projet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqcreation_projet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqcreation_projet OWNER TO postgres;

--
-- Name: seqdevise; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqdevise
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqdevise OWNER TO postgres;

--
-- Name: seqdiplome; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqdiplome
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqdiplome OWNER TO postgres;

--
-- Name: seqdomaine; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqdomaine
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqdomaine OWNER TO postgres;

--
-- Name: seqdonation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqdonation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqdonation OWNER TO postgres;

--
-- Name: seqecole; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqecole
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqecole OWNER TO postgres;

--
-- Name: seqentite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqentite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqentite OWNER TO postgres;

--
-- Name: seqentreprise; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqentreprise
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqentreprise OWNER TO postgres;

--
-- Name: seqequipe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqequipe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqequipe OWNER TO postgres;

--
-- Name: seqexecution_script; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqexecution_script
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqexecution_script OWNER TO postgres;

--
-- Name: seqexecution_scriptfille; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqexecution_scriptfille
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqexecution_scriptfille OWNER TO postgres;

--
-- Name: seqexecutions; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqexecutions
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqexecutions OWNER TO postgres;

--
-- Name: seqexperience; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqexperience
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqexperience OWNER TO postgres;

--
-- Name: seqexternal_work; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqexternal_work
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqexternal_work OWNER TO postgres;

--
-- Name: seqfonctionnalite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqfonctionnalite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqfonctionnalite OWNER TO postgres;

--
-- Name: seqfournisseur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqfournisseur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqfournisseur OWNER TO postgres;

--
-- Name: seqgroupemembres; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqgroupemembres
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqgroupemembres OWNER TO postgres;

--
-- Name: seqgroupes; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqgroupes
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqgroupes OWNER TO postgres;

--
-- Name: seqhistoimport; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqhistoimport
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqhistoimport OWNER TO postgres;

--
-- Name: seqhistorique; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqhistorique
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqhistorique OWNER TO postgres;

--
-- Name: seqhistoriqueactif; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqhistoriqueactif
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqhistoriqueactif OWNER TO postgres;

--
-- Name: seqhistoriquevaleur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqhistoriquevaleur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqhistoriquevaleur OWNER TO postgres;

--
-- Name: seqhistovaleur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqhistovaleur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqhistovaleur OWNER TO postgres;

--
-- Name: seqingredients; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqingredients
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqingredients OWNER TO postgres;

--
-- Name: seqmagasin; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmagasin
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqmagasin OWNER TO postgres;

--
-- Name: seqmailcc; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmailcc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqmailcc OWNER TO postgres;

--
-- Name: seqmailrapport; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmailrapport
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqmailrapport OWNER TO postgres;

--
-- Name: seqmenudynamique; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmenudynamique
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqmenudynamique OWNER TO postgres;

--
-- Name: seqmetier; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmetier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqmetier OWNER TO postgres;

--
-- Name: seqmetierrelation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmetierrelation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqmetierrelation OWNER TO postgres;

--
-- Name: seqmoderationutilisateur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmoderationutilisateur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqmoderationutilisateur OWNER TO postgres;

--
-- Name: seqmotifavoirfc; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmotifavoirfc
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqmotifavoirfc OWNER TO postgres;

--
-- Name: seqmouvementcaisse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmouvementcaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqmouvementcaisse OWNER TO postgres;

--
-- Name: seqmvtcaisseprevision; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqmvtcaisseprevision
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqmvtcaisseprevision OWNER TO postgres;

--
-- Name: seqniveau; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqniveau
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqniveau OWNER TO postgres;

--
-- Name: seqnotificationaction; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqnotificationaction
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqnotificationaction OWNER TO postgres;

--
-- Name: seqoption; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqoption
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqoption OWNER TO postgres;

--
-- Name: seqordonnerpaiement; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqordonnerpaiement
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqordonnerpaiement OWNER TO postgres;

--
-- Name: seqpage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqpage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqpage OWNER TO postgres;

--
-- Name: seqpagerelation; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqpagerelation
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqpagerelation OWNER TO postgres;

--
-- Name: seqparamcrypt; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqparamcrypt
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqparamcrypt OWNER TO postgres;

--
-- Name: seqparcours; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqparcours
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqparcours OWNER TO postgres;

--
-- Name: seqpays; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqpays
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqpays OWNER TO postgres;

--
-- Name: seqphase; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqphase
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqphase OWNER TO postgres;

--
-- Name: seqpiecejointe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqpiecejointe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqpiecejointe OWNER TO postgres;

--
-- Name: seqpoint; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqpoint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqpoint OWNER TO postgres;

--
-- Name: seqprevision; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqprevision
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqprevision OWNER TO postgres;

--
-- Name: seqprojet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqprojet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqprojet OWNER TO postgres;

--
-- Name: seqprojetequipe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqprojetequipe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqprojetequipe OWNER TO postgres;

--
-- Name: seqpromesse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqpromesse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqpromesse OWNER TO postgres;

--
-- Name: seqpromotion; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqpromotion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqpromotion OWNER TO postgres;

--
-- Name: seqrep; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqrep
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 1;


ALTER SEQUENCE public.seqrep OWNER TO postgres;

--
-- Name: seqrepd; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqrepd
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 1;


ALTER SEQUENCE public.seqrepd OWNER TO postgres;

--
-- Name: seqreportcaisse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqreportcaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqreportcaisse OWNER TO postgres;

--
-- Name: seqrequeteaenvoyer; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqrequeteaenvoyer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqrequeteaenvoyer OWNER TO postgres;

--
-- Name: seqreseauutilisateur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqreseauutilisateur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqreseauutilisateur OWNER TO postgres;

--
-- Name: seqreseauxsociaux; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqreseauxsociaux
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqreseauxsociaux OWNER TO postgres;

--
-- Name: seqrestriction; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqrestriction
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqrestriction OWNER TO postgres;

--
-- Name: seqscript_projet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqscript_projet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqscript_projet OWNER TO postgres;

--
-- Name: seqsource; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqsource
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqsource OWNER TO postgres;

--
-- Name: seqspecialite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqspecialite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqspecialite OWNER TO postgres;

--
-- Name: seqtache; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtache
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqtache OWNER TO postgres;

--
-- Name: seqtachemere; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtachemere
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtachemere OWNER TO postgres;

--
-- Name: seqtachemere_detailsdefaut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtachemere_detailsdefaut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtachemere_detailsdefaut OWNER TO postgres;

--
-- Name: seqtachemeredefaut; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtachemeredefaut
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtachemeredefaut OWNER TO postgres;

--
-- Name: seqtauxavancementmodule; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtauxavancementmodule
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqtauxavancementmodule OWNER TO postgres;

--
-- Name: seqtauxavancementprojet; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtauxavancementprojet
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqtauxavancementprojet OWNER TO postgres;

--
-- Name: seqtauxdechange; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtauxdechange
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqtauxdechange OWNER TO postgres;

--
-- Name: seqtype; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtype
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.seqtype OWNER TO postgres;

--
-- Name: seqtypeabsence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypeabsence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtypeabsence OWNER TO postgres;

--
-- Name: seqtypeaction; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypeaction
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtypeaction OWNER TO postgres;

--
-- Name: seqtypebase; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypebase
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtypebase OWNER TO postgres;

--
-- Name: seqtypecaisse; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypecaisse
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqtypecaisse OWNER TO postgres;

--
-- Name: seqtypeemploie; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypeemploie
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqtypeemploie OWNER TO postgres;

--
-- Name: seqtypefichier; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypefichier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtypefichier OWNER TO postgres;

--
-- Name: seqtypefournisseur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypefournisseur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqtypefournisseur OWNER TO postgres;

--
-- Name: seqtypemetier; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypemetier
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtypemetier OWNER TO postgres;

--
-- Name: seqtypepage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypepage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtypepage OWNER TO postgres;

--
-- Name: seqtyperepos; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtyperepos
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqtyperepos OWNER TO postgres;

--
-- Name: seqtypeutilisateur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqtypeutilisateur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqtypeutilisateur OWNER TO postgres;

--
-- Name: sequnite; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sequnite
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sequnite OWNER TO postgres;

--
-- Name: sequserequipe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sequserequipe
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 20;


ALTER SEQUENCE public.sequserequipe OWNER TO postgres;

--
-- Name: sequserhomepage; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sequserhomepage
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.sequserhomepage OWNER TO postgres;

--
-- Name: sequsermenu; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sequsermenu
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.sequsermenu OWNER TO postgres;

--
-- Name: sequtilisateur; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sequtilisateur
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999999
    CACHE 20;


ALTER SEQUENCE public.sequtilisateur OWNER TO postgres;

--
-- Name: seqvente; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqvente
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqvente OWNER TO postgres;

--
-- Name: seqventedetails; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqventedetails
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seqventedetails OWNER TO postgres;

--
-- Name: seqville; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqville
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 20;


ALTER SEQUENCE public.seqville OWNER TO postgres;

--
-- Name: seqwork_branche; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqwork_branche
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqwork_branche OWNER TO postgres;

--
-- Name: seqwork_type; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seqwork_type
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999999
    CACHE 1;


ALTER SEQUENCE public.seqwork_type OWNER TO postgres;

--
-- Name: signalements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.signalements (
    id character varying(50) NOT NULL,
    idutilisateur integer NOT NULL,
    post_id character varying(50),
    commentaire_id character varying(50),
    idmotifsignalement character varying(50) NOT NULL,
    idstatutsignalement character varying(50) NOT NULL,
    description text,
    traite_par integer,
    traite_at timestamp without time zone,
    decision text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.signalements OWNER TO postgres;

--
-- Name: TABLE signalements; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.signalements IS 'Signalements de contenu inapproprié par les utilisateurs';


--
-- Name: specialite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.specialite (
    id character varying(30) NOT NULL,
    libelle character varying(100) NOT NULL
);


ALTER TABLE public.specialite OWNER TO postgres;

--
-- Name: stage_competence; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stage_competence (
    post_id character varying(50) NOT NULL,
    idcompetence character varying(30) NOT NULL
);


ALTER TABLE public.stage_competence OWNER TO postgres;

--
-- Name: TABLE stage_competence; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.stage_competence IS 'Association many-to-many entre offres de stage et compétences';


--
-- Name: COLUMN stage_competence.post_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stage_competence.post_id IS 'FK vers post_stage';


--
-- Name: COLUMN stage_competence.idcompetence; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.stage_competence.idcompetence IS 'FK vers competence';


--
-- Name: statut_publication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.statut_publication (
    id character varying(50) NOT NULL,
    libelle character varying(100) NOT NULL,
    code character varying(50) NOT NULL,
    icon character varying(50),
    couleur character varying(20),
    description text,
    actif integer DEFAULT 1,
    ordre integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.statut_publication OWNER TO postgres;

--
-- Name: statut_signalement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.statut_signalement (
    id character varying(50) NOT NULL,
    libelle character varying(100) NOT NULL,
    code character varying(50) NOT NULL,
    icon character varying(50),
    couleur character varying(20),
    description text,
    actif integer DEFAULT 1,
    ordre integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.statut_signalement OWNER TO postgres;

--
-- Name: topics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.topics (
    id character varying(50) NOT NULL,
    nom character varying(100) NOT NULL,
    description text,
    icon character varying(50),
    couleur character varying(20),
    actif integer DEFAULT 1,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.topics OWNER TO postgres;

--
-- Name: TABLE topics; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.topics IS 'Tags/centres d''intérêt pour classifier les publications';


--
-- Name: type_emploie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.type_emploie (
    id character varying(30) NOT NULL,
    libelle character varying(100) NOT NULL
);


ALTER TABLE public.type_emploie OWNER TO postgres;

--
-- Name: type_fichier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.type_fichier (
    id character varying(50) NOT NULL,
    libelle character varying(100) NOT NULL,
    code character varying(50) NOT NULL,
    icon character varying(50),
    couleur character varying(20),
    extensions_acceptees character varying(200),
    taille_max_mo integer,
    description text,
    actif integer DEFAULT 1,
    ordre integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.type_fichier OWNER TO postgres;

--
-- Name: type_notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.type_notification (
    id character varying(50) NOT NULL,
    libelle character varying(100) NOT NULL,
    code character varying(50) NOT NULL,
    icon character varying(50),
    couleur character varying(20),
    template_message text,
    description text,
    actif integer DEFAULT 1,
    ordre integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.type_notification OWNER TO postgres;

--
-- Name: type_publication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.type_publication (
    id character varying(50) NOT NULL,
    libelle character varying(100) NOT NULL,
    code character varying(50) NOT NULL,
    icon character varying(50),
    couleur character varying(20),
    description text,
    actif integer DEFAULT 1,
    ordre integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.type_publication OWNER TO postgres;

--
-- Name: type_utilisateur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.type_utilisateur (
    id character varying(30) NOT NULL,
    libelle character varying(100) NOT NULL
);


ALTER TABLE public.type_utilisateur OWNER TO postgres;

--
-- Name: userhomepage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.userhomepage (
    id character varying(30) NOT NULL,
    codeservice character varying(50) DEFAULT ''::character varying,
    urlpage character varying(255) DEFAULT ''::character varying,
    idrole character varying(30) DEFAULT ''::character varying,
    codedir character varying(50) DEFAULT ''::character varying
);


ALTER TABLE public.userhomepage OWNER TO postgres;

--
-- Name: usermenu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usermenu (
    id character varying(50) NOT NULL,
    refuser character varying(50),
    idmenu character varying(50),
    idrole character varying(50),
    codeservice character varying(50),
    codedir character varying(50),
    interdit integer DEFAULT 0
);


ALTER TABLE public.usermenu OWNER TO postgres;

--
-- Name: utilisateur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.utilisateur (
    refuser integer NOT NULL,
    loginuser character varying(100) NOT NULL,
    pwduser character varying(255) NOT NULL,
    nomuser character varying(100) NOT NULL,
    adruser character varying(100) DEFAULT ''::character varying,
    teluser character varying(20) DEFAULT ''::character varying,
    idrole character varying(30),
    rang integer DEFAULT 0,
    prenom character varying(100) DEFAULT ''::character varying,
    etu character varying(50) DEFAULT ''::character varying,
    mail character varying(150) DEFAULT ''::character varying,
    photo character varying(255) DEFAULT ''::character varying,
    idtypeutilisateur character varying(30),
    idpromotion character varying(30),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.utilisateur OWNER TO postgres;

--
-- Name: utilisateur_interets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.utilisateur_interets (
    id character varying(50) NOT NULL,
    idutilisateur integer NOT NULL,
    topic_id character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.utilisateur_interets OWNER TO postgres;

--
-- Name: TABLE utilisateur_interets; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.utilisateur_interets IS 'Centres d''intérêt sélectionnés par les utilisateurs';


--
-- Name: utilisateur_refuser_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.utilisateur_refuser_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.utilisateur_refuser_seq OWNER TO postgres;

--
-- Name: utilisateur_refuser_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.utilisateur_refuser_seq OWNED BY public.utilisateur.refuser;


--
-- Name: utilisateur_specialite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.utilisateur_specialite (
    idutilisateur integer NOT NULL,
    idspecialite character varying(30) NOT NULL
);


ALTER TABLE public.utilisateur_specialite OWNER TO postgres;

--
-- Name: utilisateur_statut; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.utilisateur_statut AS
 SELECT u.refuser,
    u.loginuser,
    u.nomuser,
    u.idrole,
        CASE
            WHEN ((m.type_action)::text = 'leve'::text) THEN 'actif'::character varying
            WHEN (m.type_action IS NULL) THEN 'actif'::character varying
            WHEN ((m.date_expiration IS NOT NULL) AND (m.date_expiration < CURRENT_DATE)) THEN 'actif'::character varying
            ELSE m.type_action
        END AS statut,
    m.motif,
    m.date_expiration,
    m.idmoderateur
   FROM (public.utilisateur u
     LEFT JOIN LATERAL ( SELECT moderation_utilisateur.id,
            moderation_utilisateur.idutilisateur,
            moderation_utilisateur.idmoderateur,
            moderation_utilisateur.type_action,
            moderation_utilisateur.motif,
            moderation_utilisateur.date_action,
            moderation_utilisateur.date_expiration
           FROM public.moderation_utilisateur
          WHERE (moderation_utilisateur.idutilisateur = u.refuser)
          ORDER BY moderation_utilisateur.date_action DESC
         LIMIT 1) m ON (true));


ALTER VIEW public.utilisateur_statut OWNER TO postgres;

--
-- Name: utilisateurrole; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.utilisateurrole AS
 SELECT refuser,
    loginuser,
    pwduser,
    nomuser,
    adruser,
    teluser,
    idrole,
    rang,
    ''::text AS service,
    COALESCE(adruser, ''::character varying) AS direction
   FROM public.utilisateur;


ALTER VIEW public.utilisateurrole OWNER TO postgres;

--
-- Name: utilisateurvalide; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.utilisateurvalide AS
 SELECT u.refuser,
    u.loginuser,
    u.pwduser,
    u.nomuser,
    u.adruser,
    u.teluser,
    u.idrole,
    u.rang,
    u.prenom,
    u.etu,
    u.mail,
    u.photo,
    u.idtypeutilisateur,
    u.idpromotion,
    u.created_at,
    ''::text AS service,
    COALESCE(u.adruser, ''::character varying) AS direction
   FROM (public.utilisateur u
     JOIN public.utilisateur_statut s ON ((s.refuser = u.refuser)))
  WHERE ((s.statut)::text = 'actif'::text);


ALTER VIEW public.utilisateurvalide OWNER TO postgres;

--
-- Name: utilisateurvue; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.utilisateurvue AS
 SELECT refuser,
    loginuser,
    pwduser,
    nomuser,
    adruser,
    teluser,
    idrole,
    rang
   FROM public.utilisateur;


ALTER VIEW public.utilisateurvue OWNER TO postgres;

--
-- Name: v_moderation_historique; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_moderation_historique AS
 SELECT m.id,
    m.idutilisateur,
    u.nomuser AS utilisateur_nom,
    u.prenom AS utilisateur_prenom,
    m.idmoderateur,
    mod.nomuser AS moderateur_nom,
    mod.prenom AS moderateur_prenom,
    m.type_action,
    m.motif,
    to_char(m.date_action, 'DD/MM/YYYY HH24:MI'::text) AS date_action,
    to_char((m.date_expiration)::timestamp with time zone, 'DD/MM/YYYY'::text) AS date_expiration
   FROM ((public.moderation_utilisateur m
     LEFT JOIN public.utilisateur u ON ((m.idutilisateur = u.refuser)))
     LEFT JOIN public.utilisateur mod ON ((m.idmoderateur = mod.refuser)))
  ORDER BY m.date_action DESC;


ALTER VIEW public.v_moderation_historique OWNER TO postgres;

--
-- Name: visibilite_publication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.visibilite_publication (
    id character varying(50) NOT NULL,
    libelle character varying(100) NOT NULL,
    code character varying(50) NOT NULL,
    icon character varying(50),
    couleur character varying(20),
    description text,
    actif integer DEFAULT 1,
    ordre integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.visibilite_publication OWNER TO postgres;

--
-- Name: v_post_activite_cpl; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_post_activite_cpl AS
 SELECT pa.post_id,
    pa.titre,
    pa.idcategorie,
    ca.libelle AS categorie_libelle,
    pa.lieu,
    pa.adresse,
    pa.date_debut,
    pa.date_fin,
    pa.prix,
    pa.nombre_places,
    pa.places_restantes,
    pa.contact_email,
    pa.contact_tel,
    pa.lien_inscription,
    pa.lien_externe,
    p.contenu,
    p.idutilisateur,
    p.idgroupe,
    p.idvisibilite,
    p.idstatutpublication,
    p.nb_likes,
    p.nb_commentaires,
    p.nb_partages,
    p.created_at,
    p.edited_at,
    p.epingle,
    p.supprime,
    COALESCE((((u.nomuser)::text || ' '::text) || (u.prenom)::text), 'Inconnu'::text) AS auteur_nom,
    sp.libelle AS statut_libelle,
    vp.libelle AS visibilite_libelle
   FROM (((((public.post_activite pa
     JOIN public.posts p ON (((p.id)::text = (pa.post_id)::text)))
     LEFT JOIN public.categorie_activite ca ON (((ca.id)::text = (pa.idcategorie)::text)))
     LEFT JOIN public.utilisateur u ON ((u.refuser = p.idutilisateur)))
     LEFT JOIN public.statut_publication sp ON (((sp.id)::text = (p.idstatutpublication)::text)))
     LEFT JOIN public.visibilite_publication vp ON (((vp.id)::text = (p.idvisibilite)::text)))
  WHERE ((p.supprime = 0) AND ((p.idtypepublication)::text = 'TYP00003'::text));


ALTER VIEW public.v_post_activite_cpl OWNER TO postgres;

--
-- Name: v_post_emploi_cpl; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_post_emploi_cpl AS
 SELECT pe.post_id,
    pe.identreprise,
    COALESCE(e.libelle, pe.entreprise) AS entreprise,
    pe.localisation,
    pe.poste,
    pe.type_contrat,
    pe.salaire_min,
    pe.salaire_max,
    pe.devise,
    pe.experience_requise,
    ( SELECT string_agg((c.libelle)::text, ', '::text ORDER BY (c.libelle)::text) AS string_agg
           FROM (public.emploi_competence ec
             JOIN public.competence c ON (((c.id)::text = (ec.idcompetence)::text)))
          WHERE ((ec.post_id)::text = (pe.post_id)::text)) AS competences_requises,
    pe.niveau_etude_requis,
    pe.teletravail_possible,
    pe.date_limite,
    pe.contact_email,
    pe.contact_tel,
    pe.lien_candidature,
    p.contenu,
    p.idutilisateur,
    p.idgroupe,
    p.idvisibilite,
    p.idstatutpublication,
    p.nb_likes,
    p.nb_commentaires,
    p.nb_partages,
    p.created_at,
    p.edited_at,
    p.epingle,
    p.supprime,
    COALESCE((((u.nomuser)::text || ' '::text) || (u.prenom)::text), 'Inconnu'::text) AS auteur_nom,
    sp.libelle AS statut_libelle,
    vp.libelle AS visibilite_libelle
   FROM (((((public.post_emploi pe
     JOIN public.posts p ON (((p.id)::text = (pe.post_id)::text)))
     LEFT JOIN public.entreprise e ON (((e.id)::text = (pe.identreprise)::text)))
     LEFT JOIN public.utilisateur u ON ((u.refuser = p.idutilisateur)))
     LEFT JOIN public.statut_publication sp ON (((sp.id)::text = (p.idstatutpublication)::text)))
     LEFT JOIN public.visibilite_publication vp ON (((vp.id)::text = (p.idvisibilite)::text)))
  WHERE ((p.supprime = 0) AND ((p.idtypepublication)::text = 'TYP00002'::text));


ALTER VIEW public.v_post_emploi_cpl OWNER TO postgres;

--
-- Name: v_post_stage_cpl; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_post_stage_cpl AS
 SELECT ps.post_id,
    ps.identreprise,
    COALESCE(e.libelle, ps.entreprise) AS entreprise,
    ps.localisation,
    ps.duree,
    ps.date_debut,
    ps.date_fin,
    ps.indemnite,
    ps.niveau_etude_requis,
    ( SELECT string_agg((c.libelle)::text, ', '::text ORDER BY (c.libelle)::text) AS string_agg
           FROM (public.stage_competence sc
             JOIN public.competence c ON (((c.id)::text = (sc.idcompetence)::text)))
          WHERE ((sc.post_id)::text = (ps.post_id)::text)) AS competences_requises,
    ps.convention_requise,
    ps.places_disponibles,
    ps.contact_email,
    ps.contact_tel,
    ps.lien_candidature,
    p.contenu,
    p.idutilisateur,
    p.idgroupe,
    p.idvisibilite,
    p.idstatutpublication,
    p.nb_likes,
    p.nb_commentaires,
    p.nb_partages,
    p.created_at,
    p.edited_at,
    p.epingle,
    p.supprime,
    COALESCE((((u.nomuser)::text || ' '::text) || (u.prenom)::text), 'Inconnu'::text) AS auteur_nom,
    sp.libelle AS statut_libelle,
    vp.libelle AS visibilite_libelle
   FROM (((((public.post_stage ps
     JOIN public.posts p ON (((p.id)::text = (ps.post_id)::text)))
     LEFT JOIN public.entreprise e ON (((e.id)::text = (ps.identreprise)::text)))
     LEFT JOIN public.utilisateur u ON ((u.refuser = p.idutilisateur)))
     LEFT JOIN public.statut_publication sp ON (((sp.id)::text = (p.idstatutpublication)::text)))
     LEFT JOIN public.visibilite_publication vp ON (((vp.id)::text = (p.idvisibilite)::text)))
  WHERE ((p.supprime = 0) AND ((p.idtypepublication)::text = 'TYP00001'::text));


ALTER VIEW public.v_post_stage_cpl OWNER TO postgres;

--
-- Name: v_posts_admin; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_posts_admin AS
 SELECT p.id,
    p.idutilisateur,
    p.idgroupe,
    p.idtypepublication,
    p.idstatutpublication,
    p.idvisibilite,
    p.contenu,
    p.epingle,
    p.supprime,
    p.date_suppression,
    p.nb_likes,
    p.nb_commentaires,
    p.nb_partages,
    p.created_at,
    p.edited_at,
    p.edited_by,
    u.nomuser,
    u.prenom,
    u.mail AS email_auteur,
    u.photo AS photo_auteur,
    concat(u.nomuser, ' ', u.prenom) AS nom_complet,
    tp.libelle AS type_libelle,
    tp.code AS type_code,
    tp.icon AS type_icon,
    tp.couleur AS type_couleur,
    sp.libelle AS statut_libelle,
    sp.code AS statut_code,
    sp.couleur AS statut_couleur,
    vp.libelle AS visibilite_libelle,
    vp.code AS visibilite_code,
    g.nom AS groupe_nom,
    (( SELECT count(*) AS count
           FROM public.likes
          WHERE ((likes.post_id)::text = (p.id)::text)))::integer AS nb_likes_reel,
    (( SELECT count(*) AS count
           FROM public.commentaires
          WHERE (((commentaires.post_id)::text = (p.id)::text) AND (commentaires.supprime = 0))))::integer AS nb_commentaires_reel,
    (( SELECT count(*) AS count
           FROM public.partages
          WHERE ((partages.post_id)::text = (p.id)::text)))::integer AS nb_partages_reel,
    (( SELECT count(*) AS count
           FROM public.post_fichiers
          WHERE ((post_fichiers.post_id)::text = (p.id)::text)))::integer AS nb_fichiers,
    (( SELECT count(*) AS count
           FROM public.signalements
          WHERE ((signalements.post_id)::text = (p.id)::text)))::integer AS nb_signalements
   FROM (((((public.posts p
     LEFT JOIN public.utilisateur u ON ((u.refuser = p.idutilisateur)))
     LEFT JOIN public.type_publication tp ON (((tp.id)::text = (p.idtypepublication)::text)))
     LEFT JOIN public.statut_publication sp ON (((sp.id)::text = (p.idstatutpublication)::text)))
     LEFT JOIN public.visibilite_publication vp ON (((vp.id)::text = (p.idvisibilite)::text)))
     LEFT JOIN public.groupes g ON (((g.id)::text = (p.idgroupe)::text)));


ALTER VIEW public.v_posts_admin OWNER TO postgres;

--
-- Name: v_posts_complets; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_posts_complets AS
 SELECT p.id,
    p.idutilisateur,
    p.idgroupe,
    p.idtypepublication,
    p.idstatutpublication,
    p.idvisibilite,
    p.contenu,
    p.epingle,
    p.supprime,
    p.date_suppression,
    p.nb_likes,
    p.nb_commentaires,
    p.nb_partages,
    p.created_at,
    p.edited_at,
    p.edited_by,
    u.nomuser,
    u.prenom,
    u.photo AS photo_auteur,
    tp.libelle AS type_libelle,
    tp.code AS type_code,
    tp.icon AS type_icon,
    tp.couleur AS type_couleur,
    sp.libelle AS statut_libelle,
    sp.code AS statut_code,
    vp.libelle AS visibilite_libelle,
    vp.code AS visibilite_code,
    g.nom AS groupe_nom,
    ( SELECT count(*) AS count
           FROM public.likes
          WHERE ((likes.post_id)::text = (p.id)::text)) AS nb_likes_reel,
    ( SELECT count(*) AS count
           FROM public.commentaires
          WHERE (((commentaires.post_id)::text = (p.id)::text) AND (commentaires.supprime = 0))) AS nb_commentaires_reel,
    ( SELECT count(*) AS count
           FROM public.partages
          WHERE ((partages.post_id)::text = (p.id)::text)) AS nb_partages_reel,
    ( SELECT count(*) AS count
           FROM public.post_fichiers
          WHERE ((post_fichiers.post_id)::text = (p.id)::text)) AS nb_fichiers
   FROM (((((public.posts p
     LEFT JOIN public.utilisateur u ON ((u.refuser = p.idutilisateur)))
     LEFT JOIN public.type_publication tp ON (((tp.id)::text = (p.idtypepublication)::text)))
     LEFT JOIN public.statut_publication sp ON (((sp.id)::text = (p.idstatutpublication)::text)))
     LEFT JOIN public.visibilite_publication vp ON (((vp.id)::text = (p.idvisibilite)::text)))
     LEFT JOIN public.groupes g ON (((g.id)::text = (p.idgroupe)::text)))
  WHERE (p.supprime = 0);


ALTER VIEW public.v_posts_complets OWNER TO postgres;

--
-- Name: v_signalements_commentaires; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_signalements_commentaires AS
 SELECT s.id,
    s.idutilisateur,
    s.commentaire_id,
    s.idmotifsignalement,
    s.idstatutsignalement,
    s.description,
    s.traite_par,
    s.traite_at,
    s.decision,
    s.created_at,
    concat(u.nomuser, ' ', u.prenom) AS signaleur_nom,
    u.mail AS signaleur_email,
    ms.libelle AS motif_libelle,
    ms.code AS motif_code,
    ms.gravite AS motif_gravite,
    ms.couleur AS motif_couleur,
    ms.icon AS motif_icon,
    ss.libelle AS statut_libelle,
    ss.code AS statut_code,
    ss.couleur AS statut_couleur,
    c.contenu AS commentaire_contenu,
    c.supprime AS commentaire_supprime,
    c.created_at AS commentaire_date,
    c.post_id AS commentaire_post_id,
    concat(uc.nomuser, ' ', uc.prenom) AS commentaire_auteur,
    concat(um.nomuser, ' ', um.prenom) AS moderateur_nom
   FROM ((((((public.signalements s
     LEFT JOIN public.utilisateur u ON ((u.refuser = s.idutilisateur)))
     LEFT JOIN public.motif_signalement ms ON (((ms.id)::text = (s.idmotifsignalement)::text)))
     LEFT JOIN public.statut_signalement ss ON (((ss.id)::text = (s.idstatutsignalement)::text)))
     LEFT JOIN public.commentaires c ON (((c.id)::text = (s.commentaire_id)::text)))
     LEFT JOIN public.utilisateur uc ON ((uc.refuser = c.idutilisateur)))
     LEFT JOIN public.utilisateur um ON ((um.refuser = s.traite_par)))
  WHERE (s.commentaire_id IS NOT NULL);


ALTER VIEW public.v_signalements_commentaires OWNER TO postgres;

--
-- Name: v_signalements_publications; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_signalements_publications AS
 SELECT s.id,
    s.idutilisateur,
    s.post_id,
    s.idmotifsignalement,
    s.idstatutsignalement,
    s.description,
    s.traite_par,
    s.traite_at,
    s.decision,
    s.created_at,
    concat(u.nomuser, ' ', u.prenom) AS signaleur_nom,
    u.mail AS signaleur_email,
    ms.libelle AS motif_libelle,
    ms.code AS motif_code,
    ms.gravite AS motif_gravite,
    ms.couleur AS motif_couleur,
    ms.icon AS motif_icon,
    ss.libelle AS statut_libelle,
    ss.code AS statut_code,
    ss.couleur AS statut_couleur,
    p.contenu AS publication_contenu,
    p.supprime AS publication_supprime,
    p.created_at AS publication_date,
    concat(up.nomuser, ' ', up.prenom) AS publication_auteur,
    concat(um.nomuser, ' ', um.prenom) AS moderateur_nom
   FROM ((((((public.signalements s
     LEFT JOIN public.utilisateur u ON ((u.refuser = s.idutilisateur)))
     LEFT JOIN public.motif_signalement ms ON (((ms.id)::text = (s.idmotifsignalement)::text)))
     LEFT JOIN public.statut_signalement ss ON (((ss.id)::text = (s.idstatutsignalement)::text)))
     LEFT JOIN public.posts p ON (((p.id)::text = (s.post_id)::text)))
     LEFT JOIN public.utilisateur up ON ((up.refuser = p.idutilisateur)))
     LEFT JOIN public.utilisateur um ON ((um.refuser = s.traite_par)))
  WHERE ((s.post_id IS NOT NULL) AND (s.commentaire_id IS NULL));


ALTER VIEW public.v_signalements_publications OWNER TO postgres;

--
-- Name: v_statistiques_posts; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_statistiques_posts AS
 SELECT tp.libelle AS type,
    sp.libelle AS statut,
    count(*) AS nb_posts,
    sum(p.nb_likes) AS total_likes,
    sum(p.nb_commentaires) AS total_commentaires,
    sum(p.nb_partages) AS total_partages,
    COALESCE(avg(p.nb_likes), (0)::numeric) AS moyenne_likes,
    max(p.created_at) AS dernier_post
   FROM ((public.posts p
     JOIN public.type_publication tp ON (((tp.id)::text = (p.idtypepublication)::text)))
     JOIN public.statut_publication sp ON (((sp.id)::text = (p.idstatutpublication)::text)))
  WHERE (p.supprime = 0)
  GROUP BY tp.libelle, sp.libelle
  ORDER BY (count(*)) DESC;


ALTER VIEW public.v_statistiques_posts OWNER TO postgres;

--
-- Name: v_top_contributeurs; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_top_contributeurs AS
SELECT
    NULL::integer AS refuser,
    NULL::character varying(100) AS nomuser,
    NULL::character varying(100) AS prenom,
    NULL::character varying(255) AS photo,
    NULL::bigint AS nb_posts,
    NULL::bigint AS nb_commentaires,
    NULL::bigint AS total_likes_recus,
    NULL::timestamp without time zone AS dernier_post;


ALTER VIEW public.v_top_contributeurs OWNER TO postgres;

--
-- Name: v_utilisateur_moderation; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_utilisateur_moderation AS
 SELECT u.refuser,
    u.loginuser,
    u.nomuser,
    u.prenom,
    u.mail,
    u.photo,
    u.idrole,
    r.descrole AS role_libelle,
    r.rang AS role_rang,
    COALESCE(s.statut, 'actif'::character varying) AS statut,
    s.motif AS dernier_motif,
    s.date_expiration,
    COALESCE(p.libelle, ''::character varying) AS promotion
   FROM (((public.utilisateur u
     LEFT JOIN public.roles r ON (((u.idrole)::text = (r.idrole)::text)))
     LEFT JOIN public.utilisateur_statut s ON ((u.refuser = s.refuser)))
     LEFT JOIN public.promotion p ON (((u.idpromotion)::text = (p.id)::text)));


ALTER VIEW public.v_utilisateur_moderation OWNER TO postgres;

--
-- Name: ville; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ville (
    id character varying(30) NOT NULL,
    libelle character varying(100) NOT NULL,
    idpays character varying(30)
);


ALTER TABLE public.ville OWNER TO postgres;

--
-- Name: v_utilisateurpg_libcpl; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_utilisateurpg_libcpl AS
 SELECT u.refuser,
    u.loginuser,
    u.nomuser,
    u.prenom,
    u.mail,
    u.teluser,
    u.adruser,
    u.photo,
    u.idtypeutilisateur,
    u.idpromotion,
    COALESCE(p.libelle, ''::character varying) AS promotion,
    COALESCE(t.libelle, ''::character varying) AS typeutilisateur,
    ( SELECT string_agg((c.libelle)::text, ', '::text) AS string_agg
           FROM (public.competence_utilisateur cu
             JOIN public.competence c ON (((cu.idcompetence)::text = (c.id)::text)))
          WHERE (cu.idutilisateur = u.refuser)) AS competence,
    ( SELECT e2.libelle
           FROM (public.experience e
             JOIN public.entreprise e2 ON (((e.identreprise)::text = (e2.id)::text)))
          WHERE (e.idutilisateur = u.refuser)
          ORDER BY e.datedebut DESC NULLS LAST
         LIMIT 1) AS entreprise,
    ( SELECT v.id
           FROM ((public.experience e
             JOIN public.entreprise ent ON (((e.identreprise)::text = (ent.id)::text)))
             JOIN public.ville v ON (((ent.idville)::text = (v.id)::text)))
          WHERE (e.idutilisateur = u.refuser)
          ORDER BY e.datedebut DESC NULLS LAST
         LIMIT 1) AS idville,
    ( SELECT v.libelle
           FROM ((public.experience e
             JOIN public.entreprise ent ON (((e.identreprise)::text = (ent.id)::text)))
             JOIN public.ville v ON (((ent.idville)::text = (v.id)::text)))
          WHERE (e.idutilisateur = u.refuser)
          ORDER BY e.datedebut DESC NULLS LAST
         LIMIT 1) AS ville,
    ( SELECT pa.id
           FROM (((public.experience e
             JOIN public.entreprise ent ON (((e.identreprise)::text = (ent.id)::text)))
             JOIN public.ville v ON (((ent.idville)::text = (v.id)::text)))
             JOIN public.pays pa ON (((v.idpays)::text = (pa.id)::text)))
          WHERE (e.idutilisateur = u.refuser)
          ORDER BY e.datedebut DESC NULLS LAST
         LIMIT 1) AS idpays,
    ( SELECT pa.libelle
           FROM (((public.experience e
             JOIN public.entreprise ent ON (((e.identreprise)::text = (ent.id)::text)))
             JOIN public.ville v ON (((ent.idville)::text = (v.id)::text)))
             JOIN public.pays pa ON (((v.idpays)::text = (pa.id)::text)))
          WHERE (e.idutilisateur = u.refuser)
          ORDER BY e.datedebut DESC NULLS LAST
         LIMIT 1) AS pays
   FROM ((public.utilisateur u
     LEFT JOIN public.promotion p ON (((u.idpromotion)::text = (p.id)::text)))
     LEFT JOIN public.type_utilisateur t ON (((u.idtypeutilisateur)::text = (t.id)::text)));


ALTER VIEW public.v_utilisateurpg_libcpl OWNER TO postgres;

--
-- Name: visibilite_utilisateur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.visibilite_utilisateur (
    idutilisateur integer NOT NULL,
    nomchamp character varying(50) NOT NULL,
    visible integer DEFAULT 1
);


ALTER TABLE public.visibilite_utilisateur OWNER TO postgres;

--
-- Name: v_visibilite_config; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_visibilite_config AS
 SELECT (u.refuser)::character varying(10) AS idutilisateur,
    (COALESCE(max(
        CASE
            WHEN ((v.nomchamp)::text = 'mail'::text) THEN v.visible
            ELSE NULL::integer
        END), 1))::character varying(2) AS visimail,
    (COALESCE(max(
        CASE
            WHEN ((v.nomchamp)::text = 'teluser'::text) THEN v.visible
            ELSE NULL::integer
        END), 1))::character varying(2) AS visiteluser,
    (COALESCE(max(
        CASE
            WHEN ((v.nomchamp)::text = 'adruser'::text) THEN v.visible
            ELSE NULL::integer
        END), 1))::character varying(2) AS visiadruser,
    (COALESCE(max(
        CASE
            WHEN ((v.nomchamp)::text = 'photo'::text) THEN v.visible
            ELSE NULL::integer
        END), 1))::character varying(2) AS visiphoto,
    (COALESCE(max(
        CASE
            WHEN ((v.nomchamp)::text = 'prenom'::text) THEN v.visible
            ELSE NULL::integer
        END), 1))::character varying(2) AS visiprenom,
    (COALESCE(max(
        CASE
            WHEN ((v.nomchamp)::text = 'nomuser'::text) THEN v.visible
            ELSE NULL::integer
        END), 1))::character varying(2) AS visinomuser,
    (COALESCE(max(
        CASE
            WHEN ((v.nomchamp)::text = 'loginuser'::text) THEN v.visible
            ELSE NULL::integer
        END), 1))::character varying(2) AS visiloginuser,
    (COALESCE(max(
        CASE
            WHEN ((v.nomchamp)::text = 'idpromotion'::text) THEN v.visible
            ELSE NULL::integer
        END), 1))::character varying(2) AS visiidpromotion
   FROM (public.utilisateur u
     LEFT JOIN public.visibilite_utilisateur v ON ((u.refuser = v.idutilisateur)))
  GROUP BY u.refuser;


ALTER VIEW public.v_visibilite_config OWNER TO postgres;

--
-- Name: utilisateur refuser; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur ALTER COLUMN refuser SET DEFAULT nextval('public.utilisateur_refuser_seq'::regclass);


--
-- Data for Name: action; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.action (id, idmere, idfille, idtype) FROM stdin;
\.


--
-- Data for Name: annulationutilisateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.annulationutilisateur (idannulationuser, refuser, daty) FROM stdin;
\.


--
-- Data for Name: calendrier_scolaire; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calendrier_scolaire (id, titre, description, date_debut, date_fin, heure_debut, heure_fin, couleur, idpromotion, created_by, created_at) FROM stdin;
CAL000001	SMATCH'IN	Evenement efa akaiky izy ity ka tongava maro hanohana ny ekipa!	2026-03-13	2026-03-22	08:00	17:00	#99c1f1		1	2026-02-27 00:00:48.046
\.


--
-- Data for Name: categorie_activite; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categorie_activite (id, libelle) FROM stdin;
CATACT001	Conférence
CATACT002	Atelier
CATACT003	Séminaire
CATACT004	Formation
CATACT005	Rencontre alumni
CATACT006	Compétition
CATACT007	Sortie
CATACT008	Autre
\.


--
-- Data for Name: commentaires; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commentaires (id, idutilisateur, post_id, parent_id, contenu, supprime, created_at, edited_at) FROM stdin;
COMM000001	82	POST000014	\N	teste commentaire.	0	2026-02-25 23:21:44.767	\N
\.


--
-- Data for Name: competence; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.competence (id, libelle) FROM stdin;
COMP0001	Java
COMP0002	Python
COMP0003	JavaScript
COMP0004	PHP
COMP0005	SQL / PostgreSQL
COMP0006	React
COMP0007	Spring Boot
COMP0008	Docker / Kubernetes
COMP0009	Git
COMP0010	Machine Learning
COMP0011	Android / Kotlin
COMP0012	Flutter
\.


--
-- Data for Name: competence_utilisateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.competence_utilisateur (idcompetence, idutilisateur) FROM stdin;
COMP0012	1
COMP0009	1
COMP0001	1
COMP0006	1
COMP0007	1
COMP0003	1
\.


--
-- Data for Name: diplome; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diplome (id, libelle) FROM stdin;
DIPL0001	Licence
DIPL0002	Master
DIPL0003	Doctorat
DIPL0004	BTS
DIPL0005	Ingénieur
DIPL0006	DUT
\.


--
-- Data for Name: direction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.direction (id, val) FROM stdin;
\.


--
-- Data for Name: domaine; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.domaine (id, libelle, idpere) FROM stdin;
DOM00001	Informatique	\N
DOM00002	Télécommunications	\N
DOM00003	Réseaux	DOM00001
DOM00004	Génie Logiciel	DOM00001
DOM00005	Intelligence Artificielle	DOM00001
DOM00006	Gestion de Projet	\N
DOM00007	Sciences des Données	DOM00001
\.


--
-- Data for Name: ecole; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ecole (id, libelle) FROM stdin;
ECOL0001	ITU (Information Technology University)
ECOL0002	ENS
ECOL0003	Université d'Antananarivo
ECOL0004	ISPM
\.


--
-- Data for Name: emploi_competence; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.emploi_competence (post_id, idcompetence) FROM stdin;
POST000008	COMP0003
POST000014	COMP0001
POST000015	COMP0001
POST000015	COMP0004
POST000015	COMP0007
POST000016	COMP0001
POST000016	COMP0004
POST000017	COMP0001
POST000017	COMP0004
\.


--
-- Data for Name: entreprise; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entreprise (id, libelle, idville, description) FROM stdin;
ENT1	BICI	\N	\N
ENT2	Yas Madagascar	\N	\N
ENT3	BNI Madagascar	\N	\N
ENT4	Orange Madagascar	\N	\N
ENT00003	Telma	\N	Opérateur télécom malgache
ENT000001	Airtel Madagascar	VILL0001	Entreprise tena tsara.
\.


--
-- Data for Name: experience; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.experience (id, idutilisateur, datedebut, datefin, poste, iddomaine, identreprise, idtypeemploie) FROM stdin;
EXP000001	1	2026-02-24	\N	Developpeur mobile	DOM00001	ENT1	TEMPL0003
EXP000002	1	2023-02-24	2024-02-24	Admin sys	DOM00003	ENT2	TEMPL0001
\.


--
-- Data for Name: generateurtable; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.generateurtable (tablename) FROM stdin;
type_fichier
promotion
type_publication
type_utilisateur
commentaires
usermenu
ville
stage_competence
statut_signalement
topics
visibilite_publication
likes
experiencepro
userhomepage
paramcrypt
posts
option
mailcc
post_stage
formation
action
statut_publication
utilisateur
signalements
post_activite
emploi_competence
parcours
post_emploi
pays
competence
entreprise
role_groupe
specialite
groupes
groupe_membres
type_emploie
roles
type_notification
post_topics
notifications
competence_utilisateur
motif_signalement
partages
historique_valeur
reseau_utilisateur
diplome
menudynamique
post_fichiers
utilisateur_interets
reseau_social
restriction
v_post_activite_cpl
categorie_activite
\.


--
-- Data for Name: groupe_membres; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groupe_membres (id, idutilisateur, idgroupe, idrole, statut, joined_at) FROM stdin;
GMBR000001	1	GRP0000001	ROLE00003	actif	2026-02-26 21:59:44.982117
GMBR000002	122	GRP0000017	ROLE00003	actif	2026-02-26 21:59:44.982117
GMBR000003	142	GRP0000001	ROLE00003	actif	2026-02-26 21:59:44.982117
\.


--
-- Data for Name: groupes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groupes (id, nom, description, photo_couverture, photo_profil, type_groupe, created_by, actif, created_at, idpromotion) FROM stdin;
GRP0000001	Promotion Faneva	Espace privé de la promotion Faneva (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P1
GRP0000002	Promotion Miritsoka	Espace privé de la promotion Miritsoka (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P2
GRP0000003	Promotion Mampionona	Espace privé de la promotion Mampionona (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P3
GRP0000004	Promotion Harena	Espace privé de la promotion Harena (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P4
GRP0000005	Promotion Soa	Espace privé de la promotion Soa (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P5
GRP0000006	Promotion Tsiky	Espace privé de la promotion Tsiky (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P6
GRP0000007	Promotion Aina	Espace privé de la promotion Aina (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P7
GRP0000008	Promotion Miaraka	Espace privé de la promotion Miaraka (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P8
GRP0000009	Promotion Fanilo	Espace privé de la promotion Fanilo (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P9
GRP0000010	Promotion Hery	Espace privé de la promotion Hery (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P10
GRP0000011	Promotion Tiana	Espace privé de la promotion Tiana (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P11
GRP0000012	Promotion Malala	Espace privé de la promotion Malala (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P12
GRP0000013	Promotion Mamy	Espace privé de la promotion Mamy (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P13
GRP0000014	Promotion Sitraka	Espace privé de la promotion Sitraka (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P14
GRP0000015	Promotion Fitiavana	Espace privé de la promotion Fitiavana (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P15
GRP0000016	Promotion Hasina	Espace privé de la promotion Hasina (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P16
GRP0000017	Promotion Ravo	Espace privé de la promotion Ravo (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P17
GRP0000018	Promotion Fetra	Espace privé de la promotion Fetra (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P18
GRP0000019	Promotion Tovo	Espace privé de la promotion Tovo (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	P19
GRP0000020	Promotion Faneva	Espace privé de la promotion Faneva (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	D1
GRP0000021	Promotion Miritsoka	Espace privé de la promotion Miritsoka (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	D2
GRP0000022	Promotion Mampionona	Espace privé de la promotion Mampionona (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	D3
GRP0000023	Promotion Harena	Espace privé de la promotion Harena (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	D4
GRP0000024	Promotion Soa	Espace privé de la promotion Soa (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	D5
GRP0000025	Promotion Tsiky	Espace privé de la promotion Tsiky (année 2026)	\N	\N	promotion	1	1	2026-02-26 21:59:44.982117	D6
\.


--
-- Data for Name: historique; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historique (idhistorique, datehistorique, heure, objet, action, idutilisateur, refobjet) FROM stdin;
EX0002872441	2026-02-22	14:05:28:986	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872461	2026-02-22	14:36:31:672	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872481	2026-02-22	15:01:25:493	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872501	2026-02-22	15:03:13:026	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872521	2026-02-22	15:08:52:554	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872541	2026-02-22	22:17:36:637	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872561	2026-02-23	01:01:09:28	utilisateurAcade.UtilisateurAcade	Insertion par SYSTEM	SYSTEM	000022
EX0002872562	2026-02-23	01:01:09:44	historique.ParamCrypt	Insertion par SYSTEM	SYSTEM	CRY000002
EX0002872581	2026-02-23	01:04:37:07	utilisateurAcade.UtilisateurAcade	Insertion par SYSTEM	SYSTEM	000042
EX0002872582	2026-02-23	01:04:37:18	historique.ParamCrypt	Insertion par SYSTEM	SYSTEM	CRY000003
EX0002872601	2026-02-23	01:06:34:95	utilisateurAcade.UtilisateurAcade	Insertion par SYSTEM	SYSTEM	62
EX0002872602	2026-02-23	01:06:35:07	historique.ParamCrypt	Insertion par SYSTEM	SYSTEM	CRY000004
EX0002872621	2026-02-23	01:28:11:80	utilisateurAcade.UtilisateurPg	Insertion par SYSTEM	SYSTEM	82
EX0002872622	2026-02-23	01:28:11:93	historique.ParamCrypt	Insertion par SYSTEM	SYSTEM	CRY000005
EX0002872641	2026-02-23	13:58:12:715	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872661	2026-02-23	14:02:09:391	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872681	2026-02-23	14:08:30:623	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872701	2026-02-23	14:10:20:149	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872721	2026-02-23	14:27:30:682	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872741	2026-02-23	14:35:39:886	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872761	2026-02-23	14:39:11:302	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872781	2026-02-23	15:01:45:059	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872801	2026-02-23	15:14:20:649	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872821	2026-02-23	15:20:54:588	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872841	2026-02-23	15:31:33:863	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872861	2026-02-23	15:33:53:243	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872881	2026-02-23	15:39:16:155	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872901	2026-02-23	15:47:43:816	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872921	2026-02-23	15:51:32:569	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872941	2026-02-23	15:54:21:592	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872961	2026-02-23	20:06:58:465	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002872981	2026-02-23	20:15:09:943	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873001	2026-02-23	20:36:24:746	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873021	2026-02-23	21:44:51:68	bean.Parcours	Insertion par 1	1	PARC000001
EX0002873041	2026-02-23	21:32:48:689	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873061	2026-02-23	21:35:25:553	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873081	2026-02-23	22:35:35:98	bean.ReseauUtilisateur	Insertion par 1	1	RSTU000001
EX0002873101	2026-02-23	21:43:40:090	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873121	2026-02-23	21:46:43:785	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873141	2026-02-23	21:51:55:444	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873161	2026-02-23	21:56:08:193	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873181	2026-02-23	22:00:03:411	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873201	2026-02-23	22:12:01:727	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873221	2026-02-23	22:19:22:556	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873241	2026-02-23	22:26:15:979	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873261	2026-02-23	22:33:20:143	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873281	2026-02-23	22:34:36:599	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873301	2026-02-23	22:35:01:684	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873321	2026-02-23	22:40:42:339	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873341	2026-02-23	23:41:36:10	bean.Parcours	Insertion par 1	1	PARC000021
EX0002873361	2026-02-23	23:46:56:74	bean.ReseauUtilisateur	Insertion par 1	1	RSTU000021
EX0002873381	2026-02-23	22:55:51:128	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873401	2026-02-23	23:30:38:254	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873421	2026-02-23	23:45:08:060	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873441	2026-02-24	00:00:02:463	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873461	2026-02-24	00:03:51:901	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873481	2026-02-24	00:18:55:725	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873501	2026-02-24	01:19:38:90	bean.Parcours	Insertion par 1	1	PARC000041
EX0002873521	2026-02-24	00:29:59:802	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873541	2026-02-24	01:30:39:88	bean.ReseauUtilisateur	Modification par 1	1	RSTU000021
EX0002873561	2026-02-24	01:38:30:40	bean.ReseauUtilisateur	Insertion par 1	1	RSTU000041
EX0002873581	2026-02-24	01:44:08:81	bean.Experience	Insertion par 1	1	EXP000001
EX0002873582	2026-02-24	01:44:08:82	bean.Experience	Insertion par 1	1	EXP000002
EX0002873601	2026-02-24	00:54:40:012	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873621	2026-02-24	01:24:09:271	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873641	2026-02-24	01:51:32:099	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873681	2026-02-24	01:51:39:433	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873741	2026-02-24	02:10:22:252	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873761	2026-02-24	02:17:03:805	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873781	2026-02-24	13:27:15:904	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873801	2026-02-24	13:31:57:709	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873821	2026-02-24	13:33:36:604	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873841	2026-02-24	13:42:25:133	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873861	2026-02-24	13:42:50:157	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873881	2026-02-24	13:51:26:510	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873901	2026-02-24	14:02:12:792	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873921	2026-02-24	14:24:55:184	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873941	2026-02-24	14:27:55:187	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873961	2026-02-24	14:32:26:914	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002873981	2026-02-24	14:36:21:200	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874001	2026-02-24	14:38:24:922	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874021	2026-02-24	14:39:02:851	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874041	2026-02-24	14:39:56:242	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874061	2026-02-24	14:41:59:675	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874081	2026-02-24	16:06:11:971	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874101	2026-02-24	18:23:47:385	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874121	2026-02-24	18:29:02:567	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874141	2026-02-24	19:29:15:134	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874161	2026-02-24	21:30:57:153	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874181	2026-02-24	21:45:06:942	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874201	2026-02-24	21:45:26:395	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874221	2026-02-24	21:50:50:011	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874241	2026-02-24	21:53:37:592	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874261	2026-02-24	21:54:55:553	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874281	2026-02-24	21:55:42:386	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874301	2026-02-24	21:56:30:189	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874321	2026-02-24	21:58:12:205	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874341	2026-02-24	22:05:42:374	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874361	2026-02-25	00:03:01:523	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874381	2026-02-25	00:22:37:402	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874401	2026-02-25	00:26:15:953	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874421	2026-02-25	12:32:56:939	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874441	2026-02-25	12:49:45:560	mg.cnaps.utilisateur.CNAPSUser	login	82	82
EX0002874461	2026-02-25	13:48:45:868	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874481	2026-02-25	14:09:44:633	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874501	2026-02-25	14:13:56:425	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874521	2026-02-25	14:25:10:515	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874541	2026-02-25	14:27:35:400	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874561	2026-02-25	14:46:09:283	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874581	2026-02-25	14:48:15:962	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874601	2026-02-25	14:52:35:831	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874621	2026-02-25	15:15:26:958	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874641	2026-02-25	16:39:23:526	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874661	2026-02-25	16:45:11:313	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874681	2026-02-25	16:46:51:508	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874701	2026-02-25	16:57:21:908	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874721	2026-02-25	17:15:51:106	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874741	2026-02-25	17:21:13:418	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874761	2026-02-25	17:37:57:840	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874781	2026-02-25	17:39:21:928	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874801	2026-02-25	18:07:54:695	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874821	2026-02-25	18:23:23:846	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874841	2026-02-25	18:28:16:834	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874861	2026-02-25	18:31:49:404	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874881	2026-02-25	18:34:14:195	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874901	2026-02-25	19:00:31:992	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874921	2026-02-25	19:22:18:980	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874941	2026-02-25	19:25:39:628	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874961	2026-02-25	19:28:08:993	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002874981	2026-02-25	19:30:51:661	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875001	2026-02-25	19:39:51:671	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875021	2026-02-25	19:49:37:461	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875041	2026-02-25	20:12:13:225	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875061	2026-02-25	21:07:20:675	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875081	2026-02-25	21:25:00:662	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875101	2026-02-25	21:39:24:548	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875121	2026-02-25	21:43:38:517	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875141	2026-02-25	21:50:24:554	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875161	2026-02-25	22:07:16:600	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875181	2026-02-25	22:20:15:073	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875201	2026-02-25	22:23:00:157	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875221	2026-02-25	22:40:56:149	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875241	2026-02-25	23:46:19:26	bean.Post	Insertion par 1	1	POST000012
EX0002875261	2026-02-25	23:46:19:30	bean.PostEmploi	Insertion par 1	1	POST000012
EX0002875281	2026-02-25	22:52:34:108	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875301	2026-02-25	23:53:07:40	bean.Post	Insertion par 1	1	POST000013
EX0002875321	2026-02-25	23:53:07:44	bean.PostEmploi	Insertion par 1	1	POST000013
EX0002875341	2026-02-25	22:58:23:277	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875361	2026-02-25	23:07:08:201	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875381	2026-02-25	24:08:48:95	bean.Post	Insertion par 1	1	POST000014
EX0002875401	2026-02-25	24:08:48:98	bean.PostEmploi	Insertion par 1	1	POST000014
EX0002875421	2026-02-25	24:08:49:03	bean.PostFichier	Insertion par 1	1	PFIC000006
EX0002875441	2026-02-25	24:08:49:06	bean.PostFichier	Insertion par 1	1	PFIC000007
EX0002875461	2026-02-25	23:17:33:073	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875481	2026-02-25	23:18:45:588	mg.cnaps.utilisateur.CNAPSUser	login	82	82
EX0002875501	2026-02-25	24:21:44:78	bean.Commentaire	Insertion par 82	82	COMM000001
EX0002875521	2026-02-25	24:21:44:87	bean.Notification	Insertion par 82	82	NOTIF000001
EX0002875541	2026-02-25	24:21:51:73	bean.Like	Insertion par 82	82	LIKE000001
EX0002875561	2026-02-25	24:21:51:80	bean.Notification	Insertion par 82	82	NOTIF000002
EX0002875581	2026-02-25	24:21:55:48	bean.Like	Insertion par 82	82	LIKE000002
EX0002875601	2026-02-25	24:21:55:54	bean.Notification	Insertion par 82	82	NOTIF000003
EX0002875621	2026-02-25	23:22:37:405	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875641	2026-02-25	23:56:25:921	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875661	2026-02-26	00:08:42:366	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875681	2026-02-26	00:39:27:983	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875701	2026-02-26	01:44:44:57	utilisateurAcade.UtilisateurPg	Insertion par SYSTEM	SYSTEM	102
EX0002875702	2026-02-26	01:44:44:61	historique.ParamCrypt	Insertion par SYSTEM	SYSTEM	CRY000006
EX0002875721	2026-02-26	01:04:29:533	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875741	2026-02-26	01:37:27:397	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875761	2026-02-26	01:41:16:191	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875781	2026-02-26	01:48:01:339	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875801	2026-02-26	01:59:42:379	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875821	2026-02-26	02:03:56:194	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875841	2026-02-26	02:52:20:157	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875861	2026-02-26	02:54:28:900	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875881	2026-02-26	02:55:48:808	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875901	2026-02-26	02:56:42:456	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875921	2026-02-26	02:59:13:628	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875941	2026-02-26	03:00:10:354	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875961	2026-02-26	03:08:42:815	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002875981	2026-02-26	03:12:03:952	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876001	2026-02-26	03:14:55:706	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876021	2026-02-26	03:15:25:979	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876041	2026-02-26	03:19:53:122	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876061	2026-02-26	03:27:52:083	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876081	2026-02-26	03:30:37:935	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876101	2026-02-26	11:35:34:439	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876121	2026-02-26	11:37:08:245	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876141	2026-02-26	11:42:10:798	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876161	2026-02-26	11:42:26:701	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876181	2026-02-26	11:50:18:457	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876201	2026-02-26	11:51:57:316	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876221	2026-02-26	11:52:15:163	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876241	2026-02-26	11:58:29:163	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876261	2026-02-26	11:59:31:410	mg.cnaps.utilisateur.CNAPSUser	login	82	82
EX0002876281	2026-02-26	12:00:19:409	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876301	2026-02-26	12:01:20:136	mg.cnaps.utilisateur.CNAPSUser	login	82	82
EX0002876321	2026-02-26	13:04:16:10	bean.Signalement	Insertion par 82	82	SIG000001
EX0002876341	2026-02-26	12:04:24:670	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876361	2026-02-26	12:09:02:356	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876381	2026-02-26	12:09:39:856	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876401	2026-02-26	12:24:26:005	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876421	2026-02-26	13:48:30:26	utilisateurAcade.UtilisateurPg	Insertion par SYSTEM	SYSTEM	122
EX0002876422	2026-02-26	13:48:30:31	historique.ParamCrypt	Insertion par SYSTEM	SYSTEM	CRY000007
EX0002876441	2026-02-26	12:48:41:832	mg.cnaps.utilisateur.CNAPSUser	login	122	122
EX0002876461	2026-02-26	13:51:20:59	utilisateurAcade.UtilisateurPg	Insertion par SYSTEM	SYSTEM	142
EX0002876462	2026-02-26	13:51:20:62	historique.ParamCrypt	Insertion par SYSTEM	SYSTEM	CRY000008
EX0002876481	2026-02-26	12:59:14:861	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876501	2026-02-26	13:55:24:521	mg.cnaps.utilisateur.CNAPSUser	login	122	122
EX0002876521	2026-02-26	13:56:32:331	mg.cnaps.utilisateur.CNAPSUser	login	122	122
EX0002876541	2026-02-26	13:56:55:535	mg.cnaps.utilisateur.CNAPSUser	login	142	142
EX0002876561	2026-02-26	14:57:38:53	bean.Entreprise	Insertion par 142	142	ENT000001
EX0002876581	2026-02-26	15:00:08:13	bean.Post	Insertion par 142	142	POST000015
EX0002876601	2026-02-26	15:00:08:16	bean.PostEmploi	Insertion par 142	142	POST000015
EX0002876621	2026-02-26	15:00:56:75	bean.Post	Insertion par 142	142	POST000016
EX0002876641	2026-02-26	15:00:56:79	bean.PostEmploi	Insertion par 142	142	POST000016
EX0002876661	2026-02-26	15:01:13:89	bean.Post	Insertion par 142	142	POST000017
EX0002876681	2026-02-26	15:01:13:92	bean.PostEmploi	Insertion par 142	142	POST000017
EX0002876701	2026-02-26	14:02:28:999	mg.cnaps.utilisateur.CNAPSUser	login	142	142
EX0002876721	2026-02-26	14:05:15:375	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876741	2026-02-26	14:06:17:266	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876761	2026-02-26	14:19:18:422	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876781	2026-02-26	14:32:51:457	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876801	2026-02-26	14:54:09:118	mg.cnaps.utilisateur.CNAPSUser	login	122	122
EX0002876821	2026-02-26	15:57:28:29	bean.Parcours	Insertion par 122	122	PARC000061
EX0002876822	2026-02-26	15:57:28:30	bean.Parcours	Insertion par 122	122	PARC000062
EX0002876841	2026-02-26	15:57:50:81	bean.Parcours	Suppression par 122	122	PARC000062
EX0002876861	2026-02-26	15:04:32:853	mg.cnaps.utilisateur.CNAPSUser	login	122	122
EX0002876881	2026-02-26	15:06:55:974	mg.cnaps.utilisateur.CNAPSUser	login	142	142
EX0002876901	2026-02-26	15:09:22:807	mg.cnaps.utilisateur.CNAPSUser	login	142	142
EX0002876921	2026-02-26	15:11:18:565	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876941	2026-02-26	15:12:57:590	mg.cnaps.utilisateur.CNAPSUser	login	142	142
EX0002876961	2026-02-26	22:03:14:582	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002876981	2026-02-26	22:14:22:097	mg.cnaps.utilisateur.CNAPSUser	login	122	122
EX0002877001	2026-02-26	23:27:18:27	bean.Signalement	Insertion par 122	122	SIG000002
EX0002877021	2026-02-26	22:27:24:611	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002877041	2026-02-26	22:30:38:980	mg.cnaps.utilisateur.CNAPSUser	login	122	122
EX0002877061	2026-02-26	22:31:56:616	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002877081	2026-02-26	23:32:15:11	bean.Signalement	Insertion par 1	1	SIG000003
EX0002877101	2026-02-26	22:32:26:521	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002877121	2026-02-26	22:36:55:928	mg.cnaps.utilisateur.CNAPSUser	login	122	122
EX0002877141	2026-02-26	22:38:31:832	mg.cnaps.utilisateur.CNAPSUser	login	122	122
EX0002877161	2026-02-26	23:19:22:812	mg.cnaps.utilisateur.CNAPSUser	login	122	122
EX0002877181	2026-02-26	23:40:10:208	mg.cnaps.utilisateur.CNAPSUser	login	122	122
EX0002877201	2026-02-26	23:56:08:525	mg.cnaps.utilisateur.CNAPSUser	login	122	122
EX0002877221	2026-02-26	23:57:43:466	mg.cnaps.utilisateur.CNAPSUser	login	122	122
EX0002877241	2026-02-26	23:59:08:240	mg.cnaps.utilisateur.CNAPSUser	login	1	1
EX0002877261	2026-02-27	01:00:48:06	bean.CalendrierScolaire	Insertion par 1	1	CAL000001
\.


--
-- Data for Name: historique_valeur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historique_valeur (id, idhisto, refhisto, nom_table, nom_classe, val1, val2, val3, val4, val5, val6, val7, val8, val9, val10, val11, val12, val13, val14, val15, val16, val17, val18, val19, val20, val21, val22, val23, val24, val25, val26, val27, val28, val29, val30, val31, val32, val33, val34, val35, val36, val37, val38, val39, val40) FROM stdin;
\.


--
-- Data for Name: likes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.likes (id, idutilisateur, post_id, created_at) FROM stdin;
\.


--
-- Data for Name: mailcc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mailcc (id, mail) FROM stdin;
\.


--
-- Data for Name: menudynamique; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.menudynamique (id, libelle, icone, href, rang, niveau, id_pere) FROM stdin;
MENDYNPROFIL	Profil	person	#	1	1	\N
MENDYNANNUAIRE	Annuaire	group	#	2	1	\N
MENDYNADMIN	Modération	shield	#	3	1	\N
MENDYNCARRIERE	Espace Carrière	work	#	4	1	\N
MENDYNPROFIL-1	Mon profil	badge	module.jsp?but=profil/mon-profil.jsp	1	2	MENDYNPROFIL
MENDYNPROFIL-2	Mes compétences	star	module.jsp?but=profil/competence-saisie.jsp	2	2	MENDYNPROFIL
MENDYNPROFIL-3	Confidentialité	lock	module.jsp?but=profil/visibilite.jsp	3	2	MENDYNPROFIL
MENDYNANNUAIRE-1	Recherche alumni	search	module.jsp?but=annuaire/annuaire-liste.jsp	1	2	MENDYNANNUAIRE
MENDYNCARRIERE-1	Tableau de bord	dashboard	module.jsp?but=carriere/carriere-accueil.jsp	1	2	MENDYNCARRIERE
MENDYNCARRIERE-2	Emplois	business_center	#	2	2	MENDYNCARRIERE
MENDYNCARRIERE-3	Stages	school	#	3	2	MENDYNCARRIERE
MENDYNCARRIERE-4	Activités / Événements	event	#	4	2	MENDYNCARRIERE
MENDYNCARRIERE-2-1	Liste des emplois	list	module.jsp?but=carriere/emploi-liste.jsp	1	3	MENDYNCARRIERE-2
MENDYNCARRIERE-2-2	Publier un emploi	post_add	module.jsp?but=carriere/emploi-saisie.jsp	2	3	MENDYNCARRIERE-2
MENDYNCARRIERE-3-1	Liste des stages	list	module.jsp?but=carriere/stage-liste.jsp	1	3	MENDYNCARRIERE-3
MENDYNCARRIERE-3-2	Publier un stage	note_add	module.jsp?but=carriere/stage-saisie.jsp	2	3	MENDYNCARRIERE-3
MENDYNCARRIERE-4-1	Liste des activités	event_available	module.jsp?but=carriere/activite-liste.jsp	1	3	MENDYNCARRIERE-4
MENDYNCARRIERE-4-2	Publier une activité	event_note	module.jsp?but=carriere/activite-saisie.jsp	2	3	MENDYNCARRIERE-4
MENDYNADMIN-1	Gestion utilisateurs	group	module.jsp?but=moderation/moderation-liste.jsp	1	2	MENDYNADMIN
MENDYNADMIN-2	Historique	history	module.jsp?but=moderation/moderation-historique.jsp	2	2	MENDYNADMIN
MENDYNADMIN-3	Publications	article	module.jsp?but=moderation/publication-admin-liste.jsp	3	2	MENDYNADMIN
MENDYNADMIN-4	Signalements	report	module.jsp?but=moderation/signalement-liste.jsp	4	2	MENDYNADMIN
MENUALUMNICHAT	Assistant IA	chat	module.jsp?but=chatbot/alumni-chat.jsp	5	1	\N
MENDYNPROMO	Espace Promotion	school	module.jsp?but=promotion/espace-promotion.jsp	6	1	\N
MENDYN007	Calendrier	calendar_today	#	5	1	\N
MENDYN007-1	Calendrier scolaire	event	module.jsp?but=calendrier/calendrier-scolaire.jsp	1	2	MENDYN007
MENDYN007-2	Gérer événements	edit_calendar	module.jsp?but=calendrier/evenement-liste.jsp	2	2	MENDYN007
\.


--
-- Data for Name: moderation_utilisateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.moderation_utilisateur (id, idutilisateur, idmoderateur, type_action, motif, date_action, date_expiration) FROM stdin;
MU001	82	1	banni	\N	2026-02-23 10:45:05.151189	\N
MOD000001	82	1	leve	Débannissement par administrateur	2026-02-25 12:37:39.066	\N
MOD000002	82	1	banni	Miteny ratsy	2026-02-26 14:05:40.246	2026-02-28
MOD000003	82	1	leve	Débannissement par administrateur	2026-02-26 14:06:28.922	\N
MOD000004	82	1	banni	MIteny ratsy	2026-02-26 14:48:13.512	\N
\.


--
-- Data for Name: motif_signalement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.motif_signalement (id, libelle, code, icon, couleur, gravite, action_automatique, description, actif, ordre, created_at) FROM stdin;
MSIG00001	Spam	spam	fa-ban	#e74c3c	2	masquer_si_3_signalements	\N	1	1	2026-02-24 17:38:58.190483
MSIG00002	Contenu inapproprié	inapproprie	fa-exclamation-triangle	#f39c12	3	moderation_immediate	\N	1	2	2026-02-24 17:38:58.190483
MSIG00003	Harcèlement	harcelement	fa-user-times	#c0392b	5	blocage_temporaire	\N	1	3	2026-02-24 17:38:58.190483
MSIG00004	Fausse information	fausse_information	fa-info-circle	#3498db	2	ajouter_avertissement	\N	1	4	2026-02-24 17:38:58.190483
MSIG00005	Violation des règles	violation_regles	fa-gavel	#9b59b6	4	moderation_immediate	\N	1	5	2026-02-24 17:38:58.190483
MSIG00006	Autre	autre	fa-question-circle	#95a5a6	1	revue_manuelle	\N	1	6	2026-02-24 17:38:58.190483
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, idutilisateur, emetteur_id, idtypenotification, post_id, commentaire_id, groupe_id, contenu, lien, vu, lu_at, created_at) FROM stdin;
NOTIF000001	1	82	TNOT00002	POST000014	COMM000001	\N	test test a commenté votre publication	publication/publication-fiche.jsp&id=POST000014	0	\N	2026-02-25 23:21:44.853
NOTIF000002	1	82	TNOT00001	POST000014	\N	\N	test test a aimé votre publication	publication/publication-fiche.jsp&id=POST000014	0	\N	2026-02-25 23:21:51.789
NOTIF000003	1	82	TNOT00001	POST000014	\N	\N	test test a aimé votre publication	publication/publication-fiche.jsp&id=POST000014	0	\N	2026-02-25 23:21:55.533
\.


--
-- Data for Name: option; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.option (id, libelle) FROM stdin;
OP0000001	Design
OP0000002	Info
\.


--
-- Data for Name: paramcrypt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.paramcrypt (id, niveau, croissante, idutilisateur) FROM stdin;
CRY0000001	5	0	1
CRY000002	5	0	000022
CRY000003	5	0	000042
CRY000004	5	0	62
CRY000005	5	0	82
CRY000006	5	0	102
CRY000007	5	0	122
CRY000008	5	0	142
\.


--
-- Data for Name: parcours; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parcours (id, datedebut, datefin, idutilisateur, iddiplome, iddomaine, idecole) FROM stdin;
PARC000021	2023-10-23	\N	1	DIPL0001	DOM00001	ECOL0001
PARC000041	2026-02-24	\N	1	DIPL0002	DOM00002	ECOL0003
PARC000061	2026-02-26	\N	122	DIPL0001	DOM00001	ECOL0001
\.


--
-- Data for Name: partages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.partages (id, idutilisateur, post_id, commentaire, created_at) FROM stdin;
\.


--
-- Data for Name: pays; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pays (id, libelle) FROM stdin;
PAYS0001	Madagascar
PAYS0002	France
PAYS0003	Maurice
\.


--
-- Data for Name: post_activite; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_activite (post_id, titre, lieu, adresse, date_debut, date_fin, prix, nombre_places, places_restantes, contact_email, contact_tel, lien_inscription, lien_externe, idcategorie) FROM stdin;
POST000010	SMATCH'IN	Mahamasina	Palais des sports	2026-03-11 08:00:00	2026-03-25 08:00:00	10000	300	300	test@gmail.com	0343439685	test	test	CATACT006
POST000011	Conference IA	ITU	Andoharanofotsy	2026-03-11 08:00:00	2026-03-25 08:00:00	10000	300	300	test@gmail.com	0343439685	test	test	CATACT001
\.


--
-- Data for Name: post_emploi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_emploi (post_id, entreprise, localisation, poste, type_contrat, salaire_min, salaire_max, devise, experience_requise, competences_requises, niveau_etude_requis, teletravail_possible, date_limite, contact_email, contact_tel, lien_candidature, identreprise) FROM stdin;
POST000007	\N	Tana	Developpeur	CDD	100000.00	300000.00	MGA	No experience needed	\N	DIPL0001	1	2026-02-25	test@gmail.com	0343439685	lien	ENT1
POST000008	\N	Tana	Frontend	CD1	100000.00	1000000.00	MGA	No experience needed	\N	DIPL0002	0	2026-02-25	admin@gmail.com	0343439685	lien	ENT3
POST000014	\N	Tana	Backend	CDD	500000.00	1000000.00	MGA	No experience needed	\N	DIPL0001	0	\N	admin@gmail.com	0343439685	teste lien	ENT2
POST000015	\N	Antananarivo	Dev Backend	CDD	100000.00	500000.00	MGA	No experience needed	\N		0	\N	elyance@gmail.com	0343439685	https://github.com/RotsyFinaritra/alumni__itu_platform/pull/13	ENT000001
POST000016	\N	Antananarivo	Dev Backend	CDD	100000.00	500000.00	MGA	No experience needed	\N		0	\N	elyance@gmail.com	0343439685	https://github.com/RotsyFinaritra/alumni__itu_platform/pull/13	ENT2
POST000017	\N	Antananarivo	Dev Backend	CDD	100000.00	500000.00	MGA	No experience needed	\N		0	\N	elyance@gmail.com	0343439685	https://github.com/RotsyFinaritra/alumni__itu_platform/pull/13	ENT3
\.


--
-- Data for Name: post_fichiers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_fichiers (id, post_id, idtypefichier, nom_fichier, nom_original, chemin, taille_octets, mime_type, ordre, created_at) FROM stdin;
PFIC000001	POST000006	TFIC00001	stage_POST000006_1772033664315_0.png	black_bishop.png	carriere/stage_POST000006_1772033664315_0.png	30721	image/png	1	2026-02-25 18:34:24.305768
PFIC000002	POST000007	TFIC00001	emploi_POST000007_1772034339773_0.png	black_knight.png	carriere/emploi_POST000007_1772034339773_0.png	34601	image/png	1	2026-02-25 18:45:39.752038
PFIC000003	POST000008	TFIC00001	emploi_POST000008_1772035369908_0.png	black_rook.png	carriere/emploi_POST000008_1772035369908_0.png	17963	image/png	1	2026-02-25 19:02:49.899277
PFIC000004	POST000010	TFIC00001	activite_POST000010_1772045451987_0.png	black_queen.png	carriere/activite_POST000010_1772045451987_0.png	35563	image/png	1	2026-02-25 21:50:51.982988
PFIC000005	POST000011	TFIC00001	activite_POST000011_1772045521610_0.png	white_knight.png	carriere/activite_POST000011_1772045521610_0.png	37184	image/png	1	2026-02-25 21:52:01.60642
PFIC000006	POST000014	TFIC00001	emploi_POST000014_1772050129021_0.png	white_bishop.png	carriere/emploi_POST000014_1772050129021_0.png	4850	image/png	1	\N
PFIC000007	POST000014	TFIC00001	emploi_POST000014_1772050129053_1.png	black_knight.png	carriere/emploi_POST000014_1772050129053_1.png	3452	image/png	2	\N
\.


--
-- Data for Name: post_stage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_stage (post_id, entreprise, localisation, duree, date_debut, date_fin, indemnite, niveau_etude_requis, competences_requises, convention_requise, places_disponibles, contact_email, contact_tel, lien_candidature, identreprise) FROM stdin;
POST000006	\N	\N	3	2026-02-25	2026-05-13	0.00	DIPL0001	\N	0	10	test@gmail.com	0343439685	lien	ENT1
\.


--
-- Data for Name: post_topics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_topics (id, post_id, topic_id, created_at) FROM stdin;
PTOP00001X	POST000006	TOP00010	2026-02-25 18:34:24.305768
PTOP00002X	POST000007	TOP00011	2026-02-25 18:45:39.752038
PTOP00003X	POST000008	TOP00011	2026-02-25 19:02:49.899277
PTOP00004X	POST000010	TOP00022	2026-02-25 21:50:51.982988
PTOP00005X	POST000011	TOP00022	2026-02-25 21:52:01.60642
PTOP00006X	POST000014	TOP00011	2026-02-25 23:08:48.932
PTOP00007X	POST000015	TOP00011	2026-02-26 14:00:08.114
PTOP00008X	POST000016	TOP00011	2026-02-26 14:00:56.733
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.posts (id, idutilisateur, idgroupe, idtypepublication, idstatutpublication, idvisibilite, contenu, epingle, supprime, date_suppression, nb_likes, nb_commentaires, nb_partages, created_at, edited_at, edited_by) FROM stdin;
POST000007	1	\N	TYP00002	STAT00001	VISI00001		0	0	\N	0	0	0	2026-02-25 18:45:39.752038	\N	\N
POST000008	1	\N	TYP00002	STAT00001	VISI00001		0	0	\N	0	0	0	2026-02-25 19:02:49.899277	\N	\N
POST000010	1	\N	TYP00003	STAT00001	VISI00001		0	0	\N	0	0	0	2026-02-25 21:50:51.982988	\N	\N
POST000011	1	\N	TYP00003	STAT00001	VISI00001		0	0	\N	0	0	0	2026-02-25 21:52:01.60642	\N	\N
POST000014	1	\N	TYP00002	STAT00002	VISI00001		0	0	\N	2	1	0	2026-02-25 23:08:48.932	\N	\N
POST000006	1	\N	TYP00001	STAT00001	VISI00001		0	0	\N	0	0	0	2026-02-25 18:34:24.305768	\N	\N
POST000015	142	\N	TYP00002	STAT00002	VISI00001		0	0	\N	0	0	0	2026-02-26 14:00:08.114	\N	\N
POST000017	142	\N	TYP00002	STAT00005	VISI00001		0	1	2026-02-26 15:12:43.883	0	0	0	2026-02-26 14:01:13.874	\N	\N
POST000016	142	\N	TYP00002	STAT00005	VISI00001		0	1	2026-02-26 22:34:39.062	0	0	0	2026-02-26 14:00:56.733	\N	\N
POST000018	122	GRP0000017	TYP00004	STAT00002	VISI00004	Ho ataontsika tsara ny presentation rahampitso!	0	0	\N	0	0	0	2026-02-26 22:45:29.777	\N	\N
\.


--
-- Data for Name: promotion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion (id, libelle, annee, id_option) FROM stdin;
P1	Faneva	2026	OP0000002
P2	Miritsoka	2026	OP0000002
P3	Mampionona	2026	OP0000002
P4	Harena	2026	OP0000002
P5	Soa	2026	OP0000002
P6	Tsiky	2026	OP0000002
P7	Aina	2026	OP0000002
P8	Miaraka	2026	OP0000002
P9	Fanilo	2026	OP0000002
P10	Hery	2026	OP0000002
P11	Tiana	2026	OP0000002
P12	Malala	2026	OP0000002
P13	Mamy	2026	OP0000002
P14	Sitraka	2026	OP0000002
P15	Fitiavana	2026	OP0000002
P16	Hasina	2026	OP0000002
P17	Ravo	2026	OP0000002
P18	Fetra	2026	OP0000002
P19	Tovo	2026	OP0000002
D1	Faneva	2026	OP0000001
D2	Miritsoka	2026	OP0000001
D3	Mampionona	2026	OP0000001
D4	Harena	2026	OP0000001
D5	Soa	2026	OP0000001
D6	Tsiky	2026	OP0000001
\.


--
-- Data for Name: reseau_utilisateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reseau_utilisateur (id, idreseauxsociaux, idutilisateur, lien) FROM stdin;
RSTU000021	RSX00004	1	teste
RSTU000041	RSX00002	1	github.com/RotsyFinaritra
\.


--
-- Data for Name: reseaux_sociaux; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reseaux_sociaux (id, libelle, icone) FROM stdin;
RSX00001	LinkedIn	fa-linkedin
RSX00002	GitHub	fa-github
RSX00003	Twitter / X	fa-twitter
RSX00004	Facebook	fa-facebook
RSX00005	Portfolio personnel	fa-globe
\.


--
-- Data for Name: restriction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.restriction (id, idrole, idaction, tablename, autorisation, description, iddirection) FROM stdin;
\.


--
-- Data for Name: role_groupe; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_groupe (id, libelle, code, icon, couleur, permissions, niveau_acces, description, actif, ordre, created_at) FROM stdin;
ROLE00001	Admin	admin	fa-crown	#f39c12	["all"]	3	\N	1	1	2026-02-24 17:38:58.190483
ROLE00002	Modérateur	moderateur	fa-shield	#3498db	["moderate","post","comment","delete_others"]	2	\N	1	2	2026-02-24 17:38:58.190483
ROLE00003	Membre	membre	fa-user	#95a5a6	["post","comment","like"]	1	\N	1	3	2026-02-24 17:38:58.190483
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (idrole, descrole, rang) FROM stdin;
admin	Administrateur	1
alumni	Ancien étudiant	2
etudiant	Étudiant actuel	3
enseignant	Enseignant	4
\.


--
-- Data for Name: signalements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.signalements (id, idutilisateur, post_id, commentaire_id, idmotifsignalement, idstatutsignalement, description, traite_par, traite_at, decision, created_at) FROM stdin;
SIG000003	1	POST000016	\N	MSIG00002	SSIG00003	Cette publication ne doit pas etre la.	1	2026-02-26 22:34:39.103	Publication supprimée suite à signalement	2026-02-26 22:32:15.099
\.


--
-- Data for Name: specialite; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specialite (id, libelle) FROM stdin;
SPEC0001	Développement Web
SPEC0002	Développement Mobile
SPEC0003	DevOps
SPEC0004	Data Science
SPEC0005	Cybersécurité
SPEC0006	Cloud Computing
SPEC0007	Intelligence Artificielle
SPEC0008	Administration Réseaux
\.


--
-- Data for Name: stage_competence; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stage_competence (post_id, idcompetence) FROM stdin;
\.


--
-- Data for Name: statut_publication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.statut_publication (id, libelle, code, icon, couleur, description, actif, ordre, created_at) FROM stdin;
STAT00001	Brouillon	brouillon	fa-pencil	#95a5a6	\N	1	1	2026-02-24 17:38:58.190483
STAT00002	Publié	publie	fa-check-circle	#27ae60	\N	1	2	2026-02-24 17:38:58.190483
STAT00003	En modération	moderation	fa-clock-o	#f39c12	\N	1	3	2026-02-24 17:38:58.190483
STAT00004	Archivé	archive	fa-archive	#7f8c8d	\N	1	4	2026-02-24 17:38:58.190483
STAT00005	Supprimé	supprime	fa-trash	#e74c3c	\N	1	5	2026-02-24 17:38:58.190483
STAT00006	Expiré	expire	fa-calendar-times-o	#e67e22	\N	1	6	2026-02-24 17:38:58.190483
\.


--
-- Data for Name: statut_signalement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.statut_signalement (id, libelle, code, icon, couleur, description, actif, ordre, created_at) FROM stdin;
SSIG00001	En attente	en_attente	fa-clock-o	#f39c12	\N	1	1	2026-02-24 17:38:58.190483
SSIG00002	En cours	en_cours	fa-spinner	#3498db	\N	1	2	2026-02-24 17:38:58.190483
SSIG00003	Traité	traite	fa-check	#27ae60	\N	1	3	2026-02-24 17:38:58.190483
SSIG00004	Rejeté	rejete	fa-times	#95a5a6	\N	1	4	2026-02-24 17:38:58.190483
SSIG00005	Validé	valide	fa-check-circle	#2ecc71	\N	1	5	2026-02-24 17:38:58.190483
\.


--
-- Data for Name: topics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topics (id, nom, description, icon, couleur, actif, created_at) FROM stdin;
TOP00001	Informatique	Technologies de l'information	fa-laptop	#3498db	1	2026-02-24 17:38:58.190483
TOP00002	Génie Civil	Bâtiment et travaux publics	fa-building	#e67e22	1	2026-02-24 17:38:58.190483
TOP00003	Télécommunications	Réseaux et communications	fa-wifi	#9b59b6	1	2026-02-24 17:38:58.190483
TOP00004	Électronique	Systèmes électroniques	fa-microchip	#16a085	1	2026-02-24 17:38:58.190483
TOP00005	Management	Gestion et administration	fa-briefcase	#2c3e50	1	2026-02-24 17:38:58.190483
TOP00010	Stage	Offres de stage	fa-briefcase	#2ecc71	1	2026-02-24 17:38:58.190483
TOP00011	Emploi CDI	Emplois à durée indéterminée	fa-suitcase	#27ae60	1	2026-02-24 17:38:58.190483
TOP00012	Freelance	Missions indépendantes	fa-rocket	#f39c12	1	2026-02-24 17:38:58.190483
TOP00013	Alternance	Contrats en alternance	fa-graduation-cap	#3498db	1	2026-02-24 17:38:58.190483
TOP00020	Entrepreneuriat	Création d'entreprise	fa-lightbulb-o	#e74c3c	1	2026-02-24 17:38:58.190483
TOP00021	Startups	Culture startup	fa-rocket	#e74c3c	1	2026-02-24 17:38:58.190483
TOP00022	Événements	Conférences, ateliers	fa-calendar	#1abc9c	1	2026-02-24 17:38:58.190483
TOP00023	Formation	Formations et certifications	fa-book	#9b59b6	1	2026-02-24 17:38:58.190483
TOP00024	Networking	Réseautage professionnel	fa-users	#34495e	1	2026-02-24 17:38:58.190483
TOP00025	Innovation	Innovation et R&D	fa-flask	#e67e22	1	2026-02-24 17:38:58.190483
\.


--
-- Data for Name: type_emploie; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.type_emploie (id, libelle) FROM stdin;
TEMPL0001	CDI
TEMPL0002	CDD
TEMPL0003	Stage
TEMPL0004	Alternance
TEMPL0005	Freelance
\.


--
-- Data for Name: type_fichier; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.type_fichier (id, libelle, code, icon, couleur, extensions_acceptees, taille_max_mo, description, actif, ordre, created_at) FROM stdin;
TFIC00001	Image	image	fa-image	#3498db	jpg,jpeg,png,gif,webp	5	\N	1	1	2026-02-25 18:47:22.045858+03
TFIC00002	Document	document	fa-file-pdf-o	#e74c3c	pdf,doc,docx,xls,xlsx,ppt,pptx	10	\N	1	2	2026-02-25 18:47:22.045858+03
TFIC00003	Vidéo	video	fa-video-camera	#9b59b6	mp4,avi,mov,wmv	50	\N	1	3	2026-02-25 18:47:22.045858+03
TFIC00004	Lien	lien	fa-link	#1abc9c		0	\N	1	4	2026-02-25 18:47:22.045858+03
\.


--
-- Data for Name: type_notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.type_notification (id, libelle, code, icon, couleur, template_message, description, actif, ordre, created_at) FROM stdin;
TNOT00001	Like	like	fa-heart	#e74c3c	{user} a aimé votre publication	\N	1	1	2026-02-24 17:38:58.190483
TNOT00002	Commentaire	commentaire	fa-comment	#3498db	{user} a commenté votre publication	\N	1	2	2026-02-24 17:38:58.190483
TNOT00003	Partage	partage	fa-share	#2ecc71	{user} a partagé votre publication	\N	1	3	2026-02-24 17:38:58.190483
TNOT00004	Mention	mention	fa-at	#f39c12	{user} vous a mentionné dans un commentaire	\N	1	4	2026-02-24 17:38:58.190483
TNOT00005	Invitation groupe	invitation_groupe	fa-user-plus	#9b59b6	{user} vous a invité à rejoindre {groupe}	\N	1	5	2026-02-24 17:38:58.190483
TNOT00006	Nouveau post groupe	nouveau_post_groupe	fa-bell	#1abc9c	Nouvelle publication dans {groupe}	\N	1	6	2026-02-24 17:38:58.190483
TNOT00007	Réponse commentaire	reponse_commentaire	fa-reply	#34495e	{user} a répondu à votre commentaire	\N	1	7	2026-02-24 17:38:58.190483
\.


--
-- Data for Name: type_publication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.type_publication (id, libelle, code, icon, couleur, description, actif, ordre, created_at) FROM stdin;
TYP00001	Stage	stage	fa-briefcase	#3498db	\N	1	1	2026-02-24 17:38:58.190483
TYP00002	Emploi	emploi	fa-suitcase	#2ecc71	\N	1	2	2026-02-24 17:38:58.190483
TYP00003	Activité	activite	fa-calendar	#e74c3c	\N	1	3	2026-02-24 17:38:58.190483
TYP00004	Projet	projet	fa-rocket	#9b59b6	\N	1	4	2026-02-24 17:38:58.190483
TYP00005	Discussion	discussion	fa-comments	#34495e	\N	1	5	2026-02-24 17:38:58.190483
\.


--
-- Data for Name: type_utilisateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.type_utilisateur (id, libelle) FROM stdin;
TU0000001	Alumni
TU0000002	Étudiant
TU0000003	Enseignant
\.


--
-- Data for Name: userhomepage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.userhomepage (id, codeservice, urlpage, idrole, codedir) FROM stdin;
\.


--
-- Data for Name: usermenu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) FROM stdin;
USRM001	*	MENDYNPROFIL	\N	\N	\N	0
USRM002	*	MENDYNANNUAIRE	\N	\N	\N	0
USRM003	*	MENDYNCARRIERE	\N	\N	\N	0
USRM_CAR_1	*	MENDYNCARRIERE-2-1	\N	\N	\N	0
USRM_CAR_2	*	MENDYNCARRIERE-2-2	admin	\N	\N	0
USRM_CAR_3	*	MENDYNCARRIERE-3-1	\N	\N	\N	0
USRM_CAR_4	*	MENDYNCARRIERE-3-2	admin	\N	\N	0
USRM_CAR_5	*	MENDYNCARRIERE-4-1	\N	\N	\N	0
USRM_CAR_6	*	MENDYNCARRIERE-4-2	admin	\N	\N	0
USRM_CAR_7	*	MENDYNCARRIERE-2-2	alumni	\N	\N	0
USRM_CAR_8	*	MENDYNCARRIERE-3-2	alumni	\N	\N	0
USRM_CAR_9	*	MENDYNCARRIERE-4-2	alumni	\N	\N	0
USRM_MOD_1	\N	MENDYNADMIN	admin	\N	\N	0
USRM_MOD_2	\N	MENDYNADMIN-1	admin	\N	\N	0
USRM_MOD_3	\N	MENDYNADMIN-2	admin	\N	\N	0
USRM_MOD_4	\N	MENDYNADMIN-3	admin	\N	\N	0
USRM_MOD_5	\N	MENDYNADMIN-4	admin	\N	\N	0
USRM_ETU_1	\N	MENDYNCARRIERE-2-2	etudiant	\N	\N	1
USRM_ETU_2	\N	MENDYNCARRIERE-3-2	etudiant	\N	\N	1
USRM_ETU_3	\N	MENDYNCARRIERE-4-2	etudiant	\N	\N	1
USRMCHAT	*	MENUALUMNICHAT	\N	\N	\N	0
USRM_PROMO	*	MENDYNPROMO	\N	\N	\N	0
USRM_CAL_ALL	*	MENDYN007	\N	\N	\N	0
USRM_CAL_ALL_1	*	MENDYN007-1	\N	\N	\N	0
USRM_CAL_ADMIN	\N	MENDYN007-2	admin	\N	\N	0
\.


--
-- Data for Name: utilisateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.utilisateur (refuser, loginuser, pwduser, nomuser, adruser, teluser, idrole, rang, prenom, etu, mail, photo, idtypeutilisateur, idpromotion, created_at) FROM stdin;
1	admin	firns	Admin		0343439685	admin	0	Super		admin@alumni-itu.mg	profile_1771888299957.png	TU0000001	P1	2026-02-23 10:25:54.786234
122	Livaixxx	wtyxy	Rotsy	Anosizato	0343439685	etudiant	0	Finaritra	3184	rotsyfinaritra0@gmail.com	profile_1772099310238.jpg	TU0000002	P17	2026-02-26 12:48:30.259512
142	Elyance	jqyfshj	Elyance	Andoharanofotsy	0340965066	alumni	0	Fenohasina	586	elyance@gmail.com	profile_1772099480572.png	TU0000001	P1	2026-02-26 12:51:20.592387
82	test	yjxyj	test	test		alumni	0	test	test	test@gmail.com	\N	TU0000001	\N	2026-02-23 10:25:54.786234
\.


--
-- Data for Name: utilisateur_interets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.utilisateur_interets (id, idutilisateur, topic_id, created_at) FROM stdin;
UINT000001	122	TOP00023	2026-02-26 22:19:31.827
UINT000002	122	TOP00012	2026-02-26 22:19:31.829
UINT000003	122	TOP00001	2026-02-26 22:19:31.829
UINT000004	122	TOP00024	2026-02-26 22:19:31.83
\.


--
-- Data for Name: utilisateur_specialite; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.utilisateur_specialite (idutilisateur, idspecialite) FROM stdin;
1	SPEC0002
1	SPEC0001
1	SPEC0003
1	SPEC0004
1	SPEC0007
1	SPEC0008
122	SPEC0001
122	SPEC0007
122	SPEC0002
\.


--
-- Data for Name: ville; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ville (id, libelle, idpays) FROM stdin;
VILL0001	Antananarivo	PAYS0001
VILL0002	Toamasina	PAYS0001
VILL0003	Paris	PAYS0002
VILL0004	Port-Louis	PAYS0003
\.


--
-- Data for Name: visibilite_publication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.visibilite_publication (id, libelle, code, icon, couleur, description, actif, ordre, created_at) FROM stdin;
VISI00001	Public	public	fa-globe	#3498db	\N	1	1	2026-02-24 17:38:58.190483
VISI00002	Groupe	groupe	fa-users	#9b59b6	\N	1	2	2026-02-24 17:38:58.190483
VISI00003	Privé	prive	fa-lock	#e74c3c	\N	1	3	2026-02-24 17:38:58.190483
VISI00004	Promotion	promotion	fa-graduation-cap	#f39c12	\N	1	4	2026-02-24 17:38:58.190483
\.


--
-- Data for Name: visibilite_utilisateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.visibilite_utilisateur (idutilisateur, nomchamp, visible) FROM stdin;
1	teluser	0
122	mail	0
1	photo	1
1	prenom	1
1	nomuser	1
1	loginuser	1
1	idpromotion	1
1	mail	0
1	adruser	0
\.


--
-- Name: seq_absence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_absence', 4, true);


--
-- Name: seq_actionprojet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_actionprojet', 1, false);


--
-- Name: seq_alert; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_alert', 1680, true);


--
-- Name: seq_analyses; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_analyses', 1800, true);


--
-- Name: seq_apjclasse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_apjclasse', 34, true);


--
-- Name: seq_attribusentite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_attribusentite', 142, true);


--
-- Name: seq_attributclasse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_attributclasse', 120, true);


--
-- Name: seq_attributoracle; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_attributoracle', 1, false);


--
-- Name: seq_attributpostgres; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_attributpostgres', 1, false);


--
-- Name: seq_attributtype; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_attributtype', 1, false);


--
-- Name: seq_boutonchamp; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_boutonchamp', 1, false);


--
-- Name: seq_boutonpage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_boutonpage', 1, false);


--
-- Name: seq_branche; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_branche', 223, true);


--
-- Name: seq_caisse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_caisse', 1, false);


--
-- Name: seq_calendrier_scolaire; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_calendrier_scolaire', 1, true);


--
-- Name: seq_categorie_activite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_categorie_activite', 1, false);


--
-- Name: seq_champdynamique; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_champdynamique', 1, false);


--
-- Name: seq_champsspeciaux; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_champsspeciaux', 11, true);


--
-- Name: seq_cheminprojetuser; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_cheminprojetuser', 2, true);


--
-- Name: seq_classe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_classe', 40, true);


--
-- Name: seq_commentaires; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_commentaires', 1, true);


--
-- Name: seq_comptaclassecompte; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptaclassecompte', 1, false);


--
-- Name: seq_comptacompte; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptacompte', 1, false);


--
-- Name: seq_comptacomptebackup; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptacomptebackup', 1, false);


--
-- Name: seq_comptaecriture; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptaecriture', 520, true);


--
-- Name: seq_comptaecriturebackup; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptaecriturebackup', 1, false);


--
-- Name: seq_comptaexercice; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptaexercice', 1, false);


--
-- Name: seq_comptajournal; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptajournal', 1, false);


--
-- Name: seq_comptajournalbackup; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptajournalbackup', 1, false);


--
-- Name: seq_comptalettrage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptalettrage', 1, false);


--
-- Name: seq_comptaorigine; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptaorigine', 1, false);


--
-- Name: seq_comptasousecriture; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptasousecriture', 300, true);


--
-- Name: seq_comptasousecriturebackup; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptasousecriturebackup', 1, false);


--
-- Name: seq_comptatypecompte; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_comptatypecompte', 1, false);


--
-- Name: seq_conception_pm; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_conception_pm', 60, true);


--
-- Name: seq_connexion; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_connexion', 4, true);


--
-- Name: seq_coutprevisionnel; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_coutprevisionnel', 20, true);


--
-- Name: seq_deploiement; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_deploiement', 45, true);


--
-- Name: seq_devis; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_devis', 1280, true);


--
-- Name: seq_devisfille; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_devisfille', 680, true);


--
-- Name: seq_diagramaffichage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramaffichage', 7, true);


--
-- Name: seq_diagramclass; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramclass', 30, true);


--
-- Name: seq_diagramclasscomposant; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramclasscomposant', 18, true);


--
-- Name: seq_diagramclasscomposanttype; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramclasscomposanttype', 3, true);


--
-- Name: seq_diagramclasspackage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramclasspackage', 2, true);


--
-- Name: seq_diagramcomposant; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramcomposant', 1, false);


--
-- Name: seq_diagrampackage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagrampackage', 5, true);


--
-- Name: seq_diagramtable; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramtable', 13, true);


--
-- Name: seq_diagramtablecolonne; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_diagramtablecolonne', 1, false);


--
-- Name: seq_donation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_donation', 80, true);


--
-- Name: seq_entitescript; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_entitescript', 1, false);


--
-- Name: seq_entreprise; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_entreprise', 1, true);


--
-- Name: seq_exceptiontache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_exceptiontache', 1080, true);


--
-- Name: seq_groupe_membres; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_groupe_membres', 1, false);


--
-- Name: seq_groupes; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_groupes', 1, false);


--
-- Name: seq_histoinsert; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_histoinsert', 13174, true);


--
-- Name: seq_honoraire; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_honoraire', 1, false);


--
-- Name: seq_indisponibilite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_indisponibilite', 120, true);


--
-- Name: seq_jourrepos; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_jourrepos', 1, false);


--
-- Name: seq_likes; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_likes', 2, true);


--
-- Name: seq_magasin2; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_magasin2', 1, false);


--
-- Name: seq_mappingtypeattribut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_mappingtypeattribut', 1, false);


--
-- Name: seq_metierfille; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_metierfille', 20, true);


--
-- Name: seq_module; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_module', 260, true);


--
-- Name: seq_module_projet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_module_projet', 1, false);


--
-- Name: seq_motif_signalement; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_motif_signalement', 6, true);


--
-- Name: seq_niveauclient; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_niveauclient', 1, false);


--
-- Name: seq_notification; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_notification', 20560, true);


--
-- Name: seq_notificationdetails; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_notificationdetails', 7, true);


--
-- Name: seq_notificationgroupe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_notificationgroupe', 5, true);


--
-- Name: seq_notifications; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_notifications', 3, true);


--
-- Name: seq_notificationsignal; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_notificationsignal', 12, true);


--
-- Name: seq_pageanalyse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pageanalyse', 1, false);


--
-- Name: seq_pageanalyseattribut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pageanalyseattribut', 1, false);


--
-- Name: seq_pageattribut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pageattribut', 62, true);


--
-- Name: seq_pagefiche; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pagefiche', 1, false);


--
-- Name: seq_pageficheattribut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pageficheattribut', 1, false);


--
-- Name: seq_pageliste; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pageliste', 2, true);


--
-- Name: seq_pagelisteattribut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pagelisteattribut', 6, true);


--
-- Name: seq_pagesaisie; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pagesaisie', 17, true);


--
-- Name: seq_panalysechampfiltre; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_panalysechampfiltre', 1, false);


--
-- Name: seq_partages; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_partages', 1, false);


--
-- Name: seq_pays; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pays', 1, false);


--
-- Name: seq_phaseproject; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_phaseproject', 4180, true);


--
-- Name: seq_plistchampfiltre; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_plistchampfiltre', 1, false);


--
-- Name: seq_pointage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_pointage', 100, true);


--
-- Name: seq_post_emploi; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_post_emploi', 1, false);


--
-- Name: seq_post_fichiers; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_post_fichiers', 7, true);


--
-- Name: seq_post_stage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_post_stage', 1, false);


--
-- Name: seq_post_topics; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_post_topics', 1, false);


--
-- Name: seq_posts; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_posts', 18, true);


--
-- Name: seq_projetutilisateur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_projetutilisateur', 1080, true);


--
-- Name: seq_proposition; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_proposition', 11, true);


--
-- Name: seq_province; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_province', 1, false);


--
-- Name: seq_qualite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_qualite', 1, false);


--
-- Name: seq_relation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_relation', 34, true);


--
-- Name: seq_requeteaenvoyer; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_requeteaenvoyer', 327720, true);


--
-- Name: seq_role_groupe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_role_groupe', 3, true);


--
-- Name: seq_script; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_script', 1080, true);


--
-- Name: seq_scriptversionning; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_scriptversionning', 1120, true);


--
-- Name: seq_serveur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_serveur', 1, true);


--
-- Name: seq_signalements; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_signalements', 3, true);


--
-- Name: seq_statut_publication; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_statut_publication', 6, true);


--
-- Name: seq_statut_signalement; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_statut_signalement', 5, true);


--
-- Name: seq_tache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_tache', 184, true);


--
-- Name: seq_tache_git_details; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_tache_git_details', 260, true);


--
-- Name: seq_tache_git_mere; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_tache_git_mere', 180, true);


--
-- Name: seq_tauxhonoraire; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_tauxhonoraire', 1, false);


--
-- Name: seq_tempstravail; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_tempstravail', 1, false);


--
-- Name: seq_timingapplication; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_timingapplication', 226920, true);


--
-- Name: seq_timingsoustache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_timingsoustache', 149160, true);


--
-- Name: seq_topics; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_topics', 25, true);


--
-- Name: seq_type_fichier; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_type_fichier', 4, true);


--
-- Name: seq_type_notification; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_type_notification', 7, true);


--
-- Name: seq_type_publication; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_type_publication', 5, true);


--
-- Name: seq_type_utilisateur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_type_utilisateur', 20, true);


--
-- Name: seq_typeactionmetier; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typeactionmetier', 20, true);


--
-- Name: seq_typeattributclasse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typeattributclasse', 1, false);


--
-- Name: seq_typechampsspeciaux; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typechampsspeciaux', 1, false);


--
-- Name: seq_typeclasse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typeclasse', 1, false);


--
-- Name: seq_typedependancediagram; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typedependancediagram', 1, false);


--
-- Name: seq_typedependanceobjet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typedependanceobjet', 1, false);


--
-- Name: seq_typeliaison; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typeliaison', 1, false);


--
-- Name: seq_typemagasin; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typemagasin', 1, false);


--
-- Name: seq_typeouinon; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typeouinon', 1, false);


--
-- Name: seq_typepageanalyse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typepageanalyse', 1, false);


--
-- Name: seq_typepageliste; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typepageliste', 1, false);


--
-- Name: seq_typepagesaisie; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typepagesaisie', 1, false);


--
-- Name: seq_typeplistchampfiltre; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typeplistchampfiltre', 1, false);


--
-- Name: seq_typerelation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typerelation', 1, false);


--
-- Name: seq_typescript; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typescript', 40, true);


--
-- Name: seq_typetache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_typetache', 20, true);


--
-- Name: seq_utilisateur_interets; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_utilisateur_interets', 4, true);


--
-- Name: seq_v_classeetfiche; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_v_classeetfiche', 1, false);


--
-- Name: seq_v_classetfiche; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_v_classetfiche', 1, false);


--
-- Name: seq_visibilite_publication; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_visibilite_publication', 4, true);


--
-- Name: seqaction; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqaction', 1, false);


--
-- Name: seqactiontache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqactiontache', 1, false);


--
-- Name: seqannulationutilisateur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqannulationutilisateur', 1, false);


--
-- Name: seqarchitecture; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqarchitecture', 5, true);


--
-- Name: seqattacher_fichier; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqattacher_fichier', 113, true);


--
-- Name: seqavoirfc; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqavoirfc', 1, false);


--
-- Name: seqavoirfcfille; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqavoirfcfille', 1, false);


--
-- Name: seqbase; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqbase', 20, true);


--
-- Name: seqbaserelation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqbaserelation', 18, true);


--
-- Name: seqbranche; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqbranche', 1, false);


--
-- Name: seqcaisse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcaisse', 1, false);


--
-- Name: seqcanevatache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcanevatache', 2, true);


--
-- Name: seqcateging; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcateging', 1, false);


--
-- Name: seqcategorie; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcategorie', 100, true);


--
-- Name: seqcategorieavoirfc; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcategorieavoirfc', 1, false);


--
-- Name: seqcategoriecaisse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcategoriecaisse', 1, false);


--
-- Name: seqcategorieniveau; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcategorieniveau', 1, false);


--
-- Name: seqclient; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqclient', 58, true);


--
-- Name: seqcompetence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcompetence', 1, false);


--
-- Name: seqcote; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcote', 120, true);


--
-- Name: seqcrcontent; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcrcontent', 80, true);


--
-- Name: seqcrcontentfille; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcrcontentfille', 80, true);


--
-- Name: seqcreation_projet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqcreation_projet', 5100, true);


--
-- Name: seqdevise; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqdevise', 1, false);


--
-- Name: seqdiplome; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqdiplome', 1, false);


--
-- Name: seqdomaine; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqdomaine', 1, false);


--
-- Name: seqdonation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqdonation', 7080, true);


--
-- Name: seqecole; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqecole', 1, false);


--
-- Name: seqentite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqentite', 4098, true);


--
-- Name: seqentreprise; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqentreprise', 1, false);


--
-- Name: seqequipe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqequipe', 20, true);


--
-- Name: seqexecution_script; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqexecution_script', 7, true);


--
-- Name: seqexecution_scriptfille; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqexecution_scriptfille', 7, true);


--
-- Name: seqexecutions; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqexecutions', 2, true);


--
-- Name: seqexperience; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqexperience', 20, true);


--
-- Name: seqexternal_work; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqexternal_work', 2, true);


--
-- Name: seqfonctionnalite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqfonctionnalite', 425, true);


--
-- Name: seqfournisseur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqfournisseur', 1, false);


--
-- Name: seqgroupemembres; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqgroupemembres', 3, true);


--
-- Name: seqgroupes; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqgroupes', 25, true);


--
-- Name: seqhistoimport; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqhistoimport', 6960, true);


--
-- Name: seqhistorique; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqhistorique', 2877280, true);


--
-- Name: seqhistoriqueactif; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqhistoriqueactif', 9, true);


--
-- Name: seqhistoriquevaleur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqhistoriquevaleur', 1, false);


--
-- Name: seqhistovaleur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqhistovaleur', 8280, true);


--
-- Name: seqingredients; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqingredients', 1, false);


--
-- Name: seqmagasin; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmagasin', 1, false);


--
-- Name: seqmailcc; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmailcc', 1, false);


--
-- Name: seqmailrapport; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmailrapport', 60, true);


--
-- Name: seqmenudynamique; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmenudynamique', 1, false);


--
-- Name: seqmetier; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmetier', 932, true);


--
-- Name: seqmetierrelation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmetierrelation', 1, true);


--
-- Name: seqmoderationutilisateur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmoderationutilisateur', 4, true);


--
-- Name: seqmotifavoirfc; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmotifavoirfc', 1, false);


--
-- Name: seqmouvementcaisse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmouvementcaisse', 21, true);


--
-- Name: seqmvtcaisseprevision; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqmvtcaisseprevision', 1, false);


--
-- Name: seqniveau; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqniveau', 1, false);


--
-- Name: seqnotificationaction; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqnotificationaction', 1, false);


--
-- Name: seqoption; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqoption', 1, false);


--
-- Name: seqordonnerpaiement; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqordonnerpaiement', 1, false);


--
-- Name: seqpage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqpage', 8268, true);


--
-- Name: seqpagerelation; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqpagerelation', 1, false);


--
-- Name: seqparamcrypt; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqparamcrypt', 8, true);


--
-- Name: seqparcours; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqparcours', 80, true);


--
-- Name: seqpays; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqpays', 1, false);


--
-- Name: seqphase; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqphase', 3, true);


--
-- Name: seqpiecejointe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqpiecejointe', 211, true);


--
-- Name: seqpoint; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqpoint', 1, false);


--
-- Name: seqprevision; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqprevision', 1, false);


--
-- Name: seqprojet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqprojet', 1, true);


--
-- Name: seqprojetequipe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqprojetequipe', 100, true);


--
-- Name: seqpromesse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqpromesse', 1, false);


--
-- Name: seqpromotion; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqpromotion', 1, false);


--
-- Name: seqrep; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqrep', 1, false);


--
-- Name: seqrepd; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqrepd', 1, false);


--
-- Name: seqreportcaisse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqreportcaisse', 100, true);


--
-- Name: seqrequeteaenvoyer; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqrequeteaenvoyer', 1, false);


--
-- Name: seqreseauutilisateur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqreseauutilisateur', 60, true);


--
-- Name: seqreseauxsociaux; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqreseauxsociaux', 1, false);


--
-- Name: seqrestriction; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqrestriction', 1, false);


--
-- Name: seqscript_projet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqscript_projet', 85, true);


--
-- Name: seqsource; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqsource', 1, false);


--
-- Name: seqspecialite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqspecialite', 1, false);


--
-- Name: seqtache; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtache', 339659, true);


--
-- Name: seqtachemere; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtachemere', 17726, true);


--
-- Name: seqtachemere_detailsdefaut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtachemere_detailsdefaut', 1, false);


--
-- Name: seqtachemeredefaut; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtachemeredefaut', 1, false);


--
-- Name: seqtauxavancementmodule; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtauxavancementmodule', 1, false);


--
-- Name: seqtauxavancementprojet; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtauxavancementprojet', 1, false);


--
-- Name: seqtauxdechange; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtauxdechange', 1, false);


--
-- Name: seqtype; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtype', 100, true);


--
-- Name: seqtypeabsence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypeabsence', 1, false);


--
-- Name: seqtypeaction; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypeaction', 1, false);


--
-- Name: seqtypebase; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypebase', 2, true);


--
-- Name: seqtypecaisse; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypecaisse', 1, false);


--
-- Name: seqtypeemploie; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypeemploie', 1, false);


--
-- Name: seqtypefichier; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypefichier', 1, false);


--
-- Name: seqtypefournisseur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypefournisseur', 1, false);


--
-- Name: seqtypemetier; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypemetier', 2, true);


--
-- Name: seqtypepage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypepage', 4, true);


--
-- Name: seqtyperepos; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtyperepos', 1, false);


--
-- Name: seqtypeutilisateur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqtypeutilisateur', 3, true);


--
-- Name: sequnite; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sequnite', 1, false);


--
-- Name: sequserequipe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sequserequipe', 120, true);


--
-- Name: sequserhomepage; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sequserhomepage', 1, false);


--
-- Name: sequsermenu; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sequsermenu', 1, false);


--
-- Name: sequtilisateur; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sequtilisateur', 161, true);


--
-- Name: seqvente; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqvente', 22, true);


--
-- Name: seqventedetails; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqventedetails', 53, true);


--
-- Name: seqville; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqville', 1, false);


--
-- Name: seqwork_branche; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqwork_branche', 1, false);


--
-- Name: seqwork_type; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seqwork_type', 1, false);


--
-- Name: utilisateur_refuser_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.utilisateur_refuser_seq', 1, false);


--
-- Name: action action_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.action
    ADD CONSTRAINT action_pkey PRIMARY KEY (id);


--
-- Name: annulationutilisateur annulationutilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annulationutilisateur
    ADD CONSTRAINT annulationutilisateur_pkey PRIMARY KEY (idannulationuser);


--
-- Name: calendrier_scolaire calendrier_scolaire_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendrier_scolaire
    ADD CONSTRAINT calendrier_scolaire_pkey PRIMARY KEY (id);


--
-- Name: categorie_activite categorie_activite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorie_activite
    ADD CONSTRAINT categorie_activite_pkey PRIMARY KEY (id);


--
-- Name: commentaires commentaires_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commentaires
    ADD CONSTRAINT commentaires_pkey PRIMARY KEY (id);


--
-- Name: competence competence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.competence
    ADD CONSTRAINT competence_pkey PRIMARY KEY (id);


--
-- Name: competence_utilisateur competence_utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.competence_utilisateur
    ADD CONSTRAINT competence_utilisateur_pkey PRIMARY KEY (idcompetence, idutilisateur);


--
-- Name: diplome diplome_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diplome
    ADD CONSTRAINT diplome_pkey PRIMARY KEY (id);


--
-- Name: direction direction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direction
    ADD CONSTRAINT direction_pkey PRIMARY KEY (id);


--
-- Name: domaine domaine_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domaine
    ADD CONSTRAINT domaine_pkey PRIMARY KEY (id);


--
-- Name: ecole ecole_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ecole
    ADD CONSTRAINT ecole_pkey PRIMARY KEY (id);


--
-- Name: emploi_competence emploi_competence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emploi_competence
    ADD CONSTRAINT emploi_competence_pkey PRIMARY KEY (post_id, idcompetence);


--
-- Name: entreprise entreprise_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entreprise
    ADD CONSTRAINT entreprise_pkey PRIMARY KEY (id);


--
-- Name: experience experience_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT experience_pkey PRIMARY KEY (id);


--
-- Name: generateurtable generateurtable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generateurtable
    ADD CONSTRAINT generateurtable_pkey PRIMARY KEY (tablename);


--
-- Name: groupe_membres groupe_membres_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupe_membres
    ADD CONSTRAINT groupe_membres_pkey PRIMARY KEY (id);


--
-- Name: groupes groupes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupes
    ADD CONSTRAINT groupes_pkey PRIMARY KEY (id);


--
-- Name: historique historique_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historique
    ADD CONSTRAINT historique_pkey PRIMARY KEY (idhistorique);


--
-- Name: historique_valeur historique_valeur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historique_valeur
    ADD CONSTRAINT historique_valeur_pkey PRIMARY KEY (id);


--
-- Name: likes likes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: mailcc mailcc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mailcc
    ADD CONSTRAINT mailcc_pkey PRIMARY KEY (id);


--
-- Name: menudynamique menudynamique_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menudynamique
    ADD CONSTRAINT menudynamique_pkey PRIMARY KEY (id);


--
-- Name: moderation_utilisateur moderation_utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_utilisateur
    ADD CONSTRAINT moderation_utilisateur_pkey PRIMARY KEY (id);


--
-- Name: motif_signalement motif_signalement_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.motif_signalement
    ADD CONSTRAINT motif_signalement_code_key UNIQUE (code);


--
-- Name: motif_signalement motif_signalement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.motif_signalement
    ADD CONSTRAINT motif_signalement_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: option option_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.option
    ADD CONSTRAINT option_pkey PRIMARY KEY (id);


--
-- Name: paramcrypt paramcrypt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paramcrypt
    ADD CONSTRAINT paramcrypt_pkey PRIMARY KEY (id);


--
-- Name: parcours parcours_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parcours
    ADD CONSTRAINT parcours_pkey PRIMARY KEY (id);


--
-- Name: partages partages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partages
    ADD CONSTRAINT partages_pkey PRIMARY KEY (id);


--
-- Name: pays pays_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pays
    ADD CONSTRAINT pays_pkey PRIMARY KEY (id);


--
-- Name: post_activite post_activite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_activite
    ADD CONSTRAINT post_activite_pkey PRIMARY KEY (post_id);


--
-- Name: post_emploi post_emploi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_emploi
    ADD CONSTRAINT post_emploi_pkey PRIMARY KEY (post_id);


--
-- Name: post_fichiers post_fichiers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_fichiers
    ADD CONSTRAINT post_fichiers_pkey PRIMARY KEY (id);


--
-- Name: post_stage post_stage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_stage
    ADD CONSTRAINT post_stage_pkey PRIMARY KEY (post_id);


--
-- Name: post_topics post_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_topics
    ADD CONSTRAINT post_topics_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: promotion promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (id);


--
-- Name: reseau_utilisateur reseau_utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reseau_utilisateur
    ADD CONSTRAINT reseau_utilisateur_pkey PRIMARY KEY (id);


--
-- Name: reseaux_sociaux reseaux_sociaux_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reseaux_sociaux
    ADD CONSTRAINT reseaux_sociaux_pkey PRIMARY KEY (id);


--
-- Name: restriction restriction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.restriction
    ADD CONSTRAINT restriction_pkey PRIMARY KEY (id);


--
-- Name: role_groupe role_groupe_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_groupe
    ADD CONSTRAINT role_groupe_code_key UNIQUE (code);


--
-- Name: role_groupe role_groupe_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_groupe
    ADD CONSTRAINT role_groupe_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (idrole);


--
-- Name: signalements signalements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.signalements
    ADD CONSTRAINT signalements_pkey PRIMARY KEY (id);


--
-- Name: specialite specialite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialite
    ADD CONSTRAINT specialite_pkey PRIMARY KEY (id);


--
-- Name: stage_competence stage_competence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stage_competence
    ADD CONSTRAINT stage_competence_pkey PRIMARY KEY (post_id, idcompetence);


--
-- Name: statut_publication statut_publication_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statut_publication
    ADD CONSTRAINT statut_publication_code_key UNIQUE (code);


--
-- Name: statut_publication statut_publication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statut_publication
    ADD CONSTRAINT statut_publication_pkey PRIMARY KEY (id);


--
-- Name: statut_signalement statut_signalement_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statut_signalement
    ADD CONSTRAINT statut_signalement_code_key UNIQUE (code);


--
-- Name: statut_signalement statut_signalement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statut_signalement
    ADD CONSTRAINT statut_signalement_pkey PRIMARY KEY (id);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: type_emploie type_emploie_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_emploie
    ADD CONSTRAINT type_emploie_pkey PRIMARY KEY (id);


--
-- Name: type_fichier type_fichier_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_fichier
    ADD CONSTRAINT type_fichier_code_key UNIQUE (code);


--
-- Name: type_fichier type_fichier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_fichier
    ADD CONSTRAINT type_fichier_pkey PRIMARY KEY (id);


--
-- Name: type_notification type_notification_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_notification
    ADD CONSTRAINT type_notification_code_key UNIQUE (code);


--
-- Name: type_notification type_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_notification
    ADD CONSTRAINT type_notification_pkey PRIMARY KEY (id);


--
-- Name: type_publication type_publication_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_publication
    ADD CONSTRAINT type_publication_code_key UNIQUE (code);


--
-- Name: type_publication type_publication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_publication
    ADD CONSTRAINT type_publication_pkey PRIMARY KEY (id);


--
-- Name: type_utilisateur type_utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_utilisateur
    ADD CONSTRAINT type_utilisateur_pkey PRIMARY KEY (id);


--
-- Name: userhomepage userhomepage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userhomepage
    ADD CONSTRAINT userhomepage_pkey PRIMARY KEY (id);


--
-- Name: usermenu usermenu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usermenu
    ADD CONSTRAINT usermenu_pkey PRIMARY KEY (id);


--
-- Name: utilisateur_interets utilisateur_interets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur_interets
    ADD CONSTRAINT utilisateur_interets_pkey PRIMARY KEY (id);


--
-- Name: utilisateur utilisateur_loginuser_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_loginuser_key UNIQUE (loginuser);


--
-- Name: utilisateur utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_pkey PRIMARY KEY (refuser);


--
-- Name: utilisateur_specialite utilisateur_specialite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur_specialite
    ADD CONSTRAINT utilisateur_specialite_pkey PRIMARY KEY (idutilisateur, idspecialite);


--
-- Name: ville ville_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ville
    ADD CONSTRAINT ville_pkey PRIMARY KEY (id);


--
-- Name: visibilite_publication visibilite_publication_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visibilite_publication
    ADD CONSTRAINT visibilite_publication_code_key UNIQUE (code);


--
-- Name: visibilite_publication visibilite_publication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visibilite_publication
    ADD CONSTRAINT visibilite_publication_pkey PRIMARY KEY (id);


--
-- Name: visibilite_utilisateur visibilite_utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visibilite_utilisateur
    ADD CONSTRAINT visibilite_utilisateur_pkey PRIMARY KEY (idutilisateur, nomchamp);


--
-- Name: idx_comments_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_parent ON public.commentaires USING btree (parent_id, created_at);


--
-- Name: idx_comments_post_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_post_date ON public.commentaires USING btree (post_id, created_at);


--
-- Name: idx_comments_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_user ON public.commentaires USING btree (idutilisateur);


--
-- Name: idx_emploi_competence_comp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_emploi_competence_comp ON public.emploi_competence USING btree (idcompetence);


--
-- Name: idx_emploi_competence_post; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_emploi_competence_post ON public.emploi_competence USING btree (post_id);


--
-- Name: idx_groupe_membres_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_groupe_membres_group ON public.groupe_membres USING btree (idgroupe);


--
-- Name: idx_groupe_membres_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_groupe_membres_role ON public.groupe_membres USING btree (idrole);


--
-- Name: idx_groupes_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_groupes_created_by ON public.groupes USING btree (created_by);


--
-- Name: idx_groupes_nom; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_groupes_nom ON public.groupes USING btree (nom);


--
-- Name: idx_likes_post; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_likes_post ON public.likes USING btree (post_id);


--
-- Name: idx_likes_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_likes_user ON public.likes USING btree (idutilisateur);


--
-- Name: idx_notifs_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifs_type ON public.notifications USING btree (idtypenotification);


--
-- Name: idx_notifs_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifs_user_date ON public.notifications USING btree (idutilisateur, created_at DESC);


--
-- Name: idx_notifs_user_vu_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifs_user_vu_date ON public.notifications USING btree (idutilisateur, vu, created_at DESC);


--
-- Name: idx_partages_post; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_partages_post ON public.partages USING btree (post_id);


--
-- Name: idx_partages_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_partages_user_date ON public.partages USING btree (idutilisateur, created_at DESC);


--
-- Name: idx_post_emploi_identreprise; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_post_emploi_identreprise ON public.post_emploi USING btree (identreprise);


--
-- Name: idx_post_emploi_poste_fts; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_post_emploi_poste_fts ON public.post_emploi USING gin (to_tsvector('french'::regconfig, (poste)::text));


--
-- Name: idx_post_fichiers_post; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_post_fichiers_post ON public.post_fichiers USING btree (post_id);


--
-- Name: idx_post_fichiers_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_post_fichiers_type ON public.post_fichiers USING btree (idtypefichier);


--
-- Name: idx_post_stage_entreprise_fts; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_post_stage_entreprise_fts ON public.post_stage USING gin (to_tsvector('french'::regconfig, (entreprise)::text));


--
-- Name: idx_post_stage_identreprise; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_post_stage_identreprise ON public.post_stage USING btree (identreprise);


--
-- Name: idx_post_topics_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_post_topics_topic ON public.post_topics USING btree (topic_id);


--
-- Name: idx_posts_contenu_fts; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_contenu_fts ON public.posts USING gin (to_tsvector('french'::regconfig, contenu));


--
-- Name: idx_posts_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_date ON public.posts USING btree (created_at DESC);


--
-- Name: idx_posts_groupe; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_groupe ON public.posts USING btree (idgroupe);


--
-- Name: idx_posts_statut_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_statut_date ON public.posts USING btree (idstatutpublication, created_at DESC);


--
-- Name: idx_posts_supprime; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_supprime ON public.posts USING btree (supprime, created_at DESC);


--
-- Name: idx_posts_type_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_type_date ON public.posts USING btree (idtypepublication, created_at DESC);


--
-- Name: idx_posts_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_user_date ON public.posts USING btree (idutilisateur, created_at DESC);


--
-- Name: idx_posts_visibilite; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_visibilite ON public.posts USING btree (idvisibilite, created_at DESC);


--
-- Name: idx_signalements_motif; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_signalements_motif ON public.signalements USING btree (idmotifsignalement);


--
-- Name: idx_signalements_post; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_signalements_post ON public.signalements USING btree (post_id);


--
-- Name: idx_signalements_statut_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_signalements_statut_date ON public.signalements USING btree (idstatutsignalement, created_at DESC);


--
-- Name: idx_signalements_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_signalements_user ON public.signalements USING btree (idutilisateur);


--
-- Name: idx_stage_competence_comp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stage_competence_comp ON public.stage_competence USING btree (idcompetence);


--
-- Name: idx_stage_competence_post; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stage_competence_post ON public.stage_competence USING btree (post_id);


--
-- Name: idx_topics_nom; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_topics_nom ON public.topics USING btree (nom);


--
-- Name: idx_user_interets_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_interets_topic ON public.utilisateur_interets USING btree (topic_id);


--
-- Name: unique_post_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_post_topic ON public.post_topics USING btree (post_id, topic_id);


--
-- Name: unique_user_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_user_group ON public.groupe_membres USING btree (idutilisateur, idgroupe);


--
-- Name: unique_user_like_post; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_user_like_post ON public.likes USING btree (idutilisateur, post_id);


--
-- Name: unique_user_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_user_topic ON public.utilisateur_interets USING btree (idutilisateur, topic_id);


--
-- Name: v_top_contributeurs _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.v_top_contributeurs AS
 SELECT u.refuser,
    u.nomuser,
    u.prenom,
    u.photo,
    count(DISTINCT p.id) AS nb_posts,
    count(DISTINCT c.id) AS nb_commentaires,
    COALESCE(sum(p.nb_likes), (0)::bigint) AS total_likes_recus,
    max(p.created_at) AS dernier_post
   FROM ((public.utilisateur u
     LEFT JOIN public.posts p ON (((p.idutilisateur = u.refuser) AND (p.supprime = 0))))
     LEFT JOIN public.commentaires c ON (((c.idutilisateur = u.refuser) AND (c.supprime = 0))))
  GROUP BY u.refuser
 HAVING ((count(DISTINCT p.id) > 0) OR (count(DISTINCT c.id) > 0))
  ORDER BY (((count(DISTINCT p.id) * 10) + count(DISTINCT c.id)) + COALESCE(sum(p.nb_likes), (0)::bigint)) DESC;


--
-- Name: posts trg_posts_edited_by_null; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_posts_edited_by_null BEFORE INSERT OR UPDATE ON public.posts FOR EACH ROW EXECUTE FUNCTION public.set_null_if_zero_edited_by();


--
-- Name: likes trigger_decrement_likes; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_decrement_likes AFTER DELETE ON public.likes FOR EACH ROW EXECUTE FUNCTION public.decrement_likes();


--
-- Name: partages trigger_decrement_partages; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_decrement_partages AFTER DELETE ON public.partages FOR EACH ROW EXECUTE FUNCTION public.decrement_partages();


--
-- Name: commentaires trigger_handle_commentaire_suppression; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_handle_commentaire_suppression AFTER UPDATE ON public.commentaires FOR EACH ROW EXECUTE FUNCTION public.handle_commentaire_suppression();


--
-- Name: commentaires trigger_increment_commentaires; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_increment_commentaires AFTER INSERT ON public.commentaires FOR EACH ROW EXECUTE FUNCTION public.increment_commentaires();


--
-- Name: likes trigger_increment_likes; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_increment_likes AFTER INSERT ON public.likes FOR EACH ROW EXECUTE FUNCTION public.increment_likes();


--
-- Name: partages trigger_increment_partages; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_increment_partages AFTER INSERT ON public.partages FOR EACH ROW EXECUTE FUNCTION public.increment_partages();


--
-- Name: post_activite trigger_init_places_restantes; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_init_places_restantes BEFORE INSERT ON public.post_activite FOR EACH ROW EXECUTE FUNCTION public.init_places_restantes();


--
-- Name: calendrier_scolaire calendrier_scolaire_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendrier_scolaire
    ADD CONSTRAINT calendrier_scolaire_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.utilisateur(refuser);


--
-- Name: commentaires commentaires_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commentaires
    ADD CONSTRAINT commentaires_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: commentaires commentaires_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commentaires
    ADD CONSTRAINT commentaires_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.commentaires(id) ON DELETE CASCADE;


--
-- Name: commentaires commentaires_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commentaires
    ADD CONSTRAINT commentaires_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: competence_utilisateur competence_utilisateur_idcompetence_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.competence_utilisateur
    ADD CONSTRAINT competence_utilisateur_idcompetence_fkey FOREIGN KEY (idcompetence) REFERENCES public.competence(id);


--
-- Name: competence_utilisateur competence_utilisateur_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.competence_utilisateur
    ADD CONSTRAINT competence_utilisateur_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: domaine domaine_idpere_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domaine
    ADD CONSTRAINT domaine_idpere_fkey FOREIGN KEY (idpere) REFERENCES public.domaine(id);


--
-- Name: emploi_competence emploi_competence_idcompetence_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emploi_competence
    ADD CONSTRAINT emploi_competence_idcompetence_fkey FOREIGN KEY (idcompetence) REFERENCES public.competence(id) ON DELETE CASCADE;


--
-- Name: emploi_competence emploi_competence_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emploi_competence
    ADD CONSTRAINT emploi_competence_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post_emploi(post_id) ON DELETE CASCADE;


--
-- Name: entreprise entreprise_idville_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entreprise
    ADD CONSTRAINT entreprise_idville_fkey FOREIGN KEY (idville) REFERENCES public.ville(id);


--
-- Name: experience experience_iddomaine_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT experience_iddomaine_fkey FOREIGN KEY (iddomaine) REFERENCES public.domaine(id);


--
-- Name: experience experience_identreprise_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT experience_identreprise_fkey FOREIGN KEY (identreprise) REFERENCES public.entreprise(id);


--
-- Name: experience experience_idtypeemploie_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT experience_idtypeemploie_fkey FOREIGN KEY (idtypeemploie) REFERENCES public.type_emploie(id);


--
-- Name: experience experience_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT experience_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: promotion fk_option; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT fk_option FOREIGN KEY (id_option) REFERENCES public.option(id);


--
-- Name: groupe_membres groupe_membres_idgroupe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupe_membres
    ADD CONSTRAINT groupe_membres_idgroupe_fkey FOREIGN KEY (idgroupe) REFERENCES public.groupes(id) ON DELETE CASCADE;


--
-- Name: groupe_membres groupe_membres_idrole_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupe_membres
    ADD CONSTRAINT groupe_membres_idrole_fkey FOREIGN KEY (idrole) REFERENCES public.role_groupe(id);


--
-- Name: groupe_membres groupe_membres_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupe_membres
    ADD CONSTRAINT groupe_membres_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: groupes groupes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupes
    ADD CONSTRAINT groupes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.utilisateur(refuser);


--
-- Name: groupes groupes_idpromotion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupes
    ADD CONSTRAINT groupes_idpromotion_fkey FOREIGN KEY (idpromotion) REFERENCES public.promotion(id);


--
-- Name: likes likes_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: likes likes_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: menudynamique menudynamique_id_pere_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menudynamique
    ADD CONSTRAINT menudynamique_id_pere_fkey FOREIGN KEY (id_pere) REFERENCES public.menudynamique(id);


--
-- Name: moderation_utilisateur moderation_utilisateur_idmoderateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_utilisateur
    ADD CONSTRAINT moderation_utilisateur_idmoderateur_fkey FOREIGN KEY (idmoderateur) REFERENCES public.utilisateur(refuser);


--
-- Name: moderation_utilisateur moderation_utilisateur_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_utilisateur
    ADD CONSTRAINT moderation_utilisateur_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: notifications notifications_commentaire_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_commentaire_id_fkey FOREIGN KEY (commentaire_id) REFERENCES public.commentaires(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_emetteur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_emetteur_id_fkey FOREIGN KEY (emetteur_id) REFERENCES public.utilisateur(refuser);


--
-- Name: notifications notifications_groupe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_groupe_id_fkey FOREIGN KEY (groupe_id) REFERENCES public.groupes(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_idtypenotification_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_idtypenotification_fkey FOREIGN KEY (idtypenotification) REFERENCES public.type_notification(id);


--
-- Name: notifications notifications_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: notifications notifications_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: parcours parcours_iddiplome_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parcours
    ADD CONSTRAINT parcours_iddiplome_fkey FOREIGN KEY (iddiplome) REFERENCES public.diplome(id);


--
-- Name: parcours parcours_iddomaine_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parcours
    ADD CONSTRAINT parcours_iddomaine_fkey FOREIGN KEY (iddomaine) REFERENCES public.domaine(id);


--
-- Name: parcours parcours_idecole_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parcours
    ADD CONSTRAINT parcours_idecole_fkey FOREIGN KEY (idecole) REFERENCES public.ecole(id);


--
-- Name: parcours parcours_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parcours
    ADD CONSTRAINT parcours_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: partages partages_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partages
    ADD CONSTRAINT partages_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: partages partages_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partages
    ADD CONSTRAINT partages_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_activite post_activite_idcategorie_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_activite
    ADD CONSTRAINT post_activite_idcategorie_fkey FOREIGN KEY (idcategorie) REFERENCES public.categorie_activite(id);


--
-- Name: post_activite post_activite_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_activite
    ADD CONSTRAINT post_activite_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_emploi post_emploi_identreprise_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_emploi
    ADD CONSTRAINT post_emploi_identreprise_fkey FOREIGN KEY (identreprise) REFERENCES public.entreprise(id);


--
-- Name: post_emploi post_emploi_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_emploi
    ADD CONSTRAINT post_emploi_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_fichiers post_fichiers_idtypefichier_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_fichiers
    ADD CONSTRAINT post_fichiers_idtypefichier_fkey FOREIGN KEY (idtypefichier) REFERENCES public.type_fichier(id);


--
-- Name: post_fichiers post_fichiers_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_fichiers
    ADD CONSTRAINT post_fichiers_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_stage post_stage_identreprise_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_stage
    ADD CONSTRAINT post_stage_identreprise_fkey FOREIGN KEY (identreprise) REFERENCES public.entreprise(id);


--
-- Name: post_stage post_stage_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_stage
    ADD CONSTRAINT post_stage_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_topics post_topics_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_topics
    ADD CONSTRAINT post_topics_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_topics post_topics_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_topics
    ADD CONSTRAINT post_topics_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(id);


--
-- Name: posts posts_edited_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_edited_by_fkey FOREIGN KEY (edited_by) REFERENCES public.utilisateur(refuser);


--
-- Name: posts posts_idstatutpublication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_idstatutpublication_fkey FOREIGN KEY (idstatutpublication) REFERENCES public.statut_publication(id);


--
-- Name: posts posts_idtypepublication_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_idtypepublication_fkey FOREIGN KEY (idtypepublication) REFERENCES public.type_publication(id);


--
-- Name: posts posts_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: posts posts_idvisibilite_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_idvisibilite_fkey FOREIGN KEY (idvisibilite) REFERENCES public.visibilite_publication(id);


--
-- Name: reseau_utilisateur reseau_utilisateur_idreseauxsociaux_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reseau_utilisateur
    ADD CONSTRAINT reseau_utilisateur_idreseauxsociaux_fkey FOREIGN KEY (idreseauxsociaux) REFERENCES public.reseaux_sociaux(id);


--
-- Name: reseau_utilisateur reseau_utilisateur_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reseau_utilisateur
    ADD CONSTRAINT reseau_utilisateur_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: signalements signalements_commentaire_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.signalements
    ADD CONSTRAINT signalements_commentaire_id_fkey FOREIGN KEY (commentaire_id) REFERENCES public.commentaires(id) ON DELETE CASCADE;


--
-- Name: signalements signalements_idmotifsignalement_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.signalements
    ADD CONSTRAINT signalements_idmotifsignalement_fkey FOREIGN KEY (idmotifsignalement) REFERENCES public.motif_signalement(id);


--
-- Name: signalements signalements_idstatutsignalement_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.signalements
    ADD CONSTRAINT signalements_idstatutsignalement_fkey FOREIGN KEY (idstatutsignalement) REFERENCES public.statut_signalement(id);


--
-- Name: signalements signalements_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.signalements
    ADD CONSTRAINT signalements_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: signalements signalements_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.signalements
    ADD CONSTRAINT signalements_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: stage_competence stage_competence_idcompetence_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stage_competence
    ADD CONSTRAINT stage_competence_idcompetence_fkey FOREIGN KEY (idcompetence) REFERENCES public.competence(id) ON DELETE CASCADE;


--
-- Name: stage_competence stage_competence_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stage_competence
    ADD CONSTRAINT stage_competence_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post_stage(post_id) ON DELETE CASCADE;


--
-- Name: usermenu usermenu_idmenu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usermenu
    ADD CONSTRAINT usermenu_idmenu_fkey FOREIGN KEY (idmenu) REFERENCES public.menudynamique(id);


--
-- Name: usermenu usermenu_idrole_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usermenu
    ADD CONSTRAINT usermenu_idrole_fkey FOREIGN KEY (idrole) REFERENCES public.roles(idrole);


--
-- Name: utilisateur utilisateur_idpromotion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_idpromotion_fkey FOREIGN KEY (idpromotion) REFERENCES public.promotion(id);


--
-- Name: utilisateur utilisateur_idrole_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_idrole_fkey FOREIGN KEY (idrole) REFERENCES public.roles(idrole);


--
-- Name: utilisateur utilisateur_idtypeutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_idtypeutilisateur_fkey FOREIGN KEY (idtypeutilisateur) REFERENCES public.type_utilisateur(id);


--
-- Name: utilisateur_interets utilisateur_interets_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur_interets
    ADD CONSTRAINT utilisateur_interets_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: utilisateur_interets utilisateur_interets_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur_interets
    ADD CONSTRAINT utilisateur_interets_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(id);


--
-- Name: utilisateur_specialite utilisateur_specialite_idspecialite_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur_specialite
    ADD CONSTRAINT utilisateur_specialite_idspecialite_fkey FOREIGN KEY (idspecialite) REFERENCES public.specialite(id);


--
-- Name: utilisateur_specialite utilisateur_specialite_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur_specialite
    ADD CONSTRAINT utilisateur_specialite_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- Name: ville ville_idpays_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ville
    ADD CONSTRAINT ville_idpays_fkey FOREIGN KEY (idpays) REFERENCES public.pays(id);


--
-- Name: visibilite_utilisateur visibilite_utilisateur_idutilisateur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visibilite_utilisateur
    ADD CONSTRAINT visibilite_utilisateur_idutilisateur_fkey FOREIGN KEY (idutilisateur) REFERENCES public.utilisateur(refuser);


--
-- PostgreSQL database dump complete
--

\unrestrict 7dz4xDoy9Q6yiXly6BIGdhzAtILmYNhhhl6gAQf23mTWjKFQPVddyrBpi4pew8b

