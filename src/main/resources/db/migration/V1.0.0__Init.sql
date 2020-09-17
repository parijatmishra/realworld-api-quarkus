--
-- Schema for PostgreSQL version 12
--
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
SET default_tablespace = '';
SET default_table_access_method = heap;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE public.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: users; Type: TABLE; Schema: public;
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    bio character varying(255),
    email character varying(255),
    image character varying(255),
    password character varying(255),
    token character varying(500),
    username character varying(255)
);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);

--
-- Name: followed_users; Type: TABLE; Schema: public;
--

CREATE TABLE public.followed_users (
    user_id bigint NOT NULL,
    followed_id bigint NOT NULL
);
ALTER TABLE ONLY public.followed_users
    ADD CONSTRAINT followed_users_pkey PRIMARY KEY (followed_id, user_id);
ALTER TABLE ONLY public.followed_users
    ADD CONSTRAINT followed_users_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE ONLY public.followed_users
    ADD CONSTRAINT followed_users_followed_id_fk FOREIGN KEY (followed_id) REFERENCES public.users(id);

--
-- Name: tags; Type: TABLE; Schema: public;
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name character varying(255)
);
ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);

--
-- Name: articles; Type: TABLE; Schema: public;
--

CREATE TABLE public.articles (
    id bigint NOT NULL,
    body character varying(255),
    createdat timestamp without time zone,
    description character varying(255),
    slug character varying(255),
    title character varying(255),
    updatedat timestamp without time zone,
    author_id bigint
);
ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_author_id_fk FOREIGN KEY (author_id) REFERENCES public.users(id);

--
-- Name: articles_tags; Type: TABLE; Schema: public;
--

CREATE TABLE public.articles_tags (
    tag_id bigint NOT NULL,
    article_id bigint NOT NULL
);
ALTER TABLE ONLY public.articles_tags
    ADD CONSTRAINT articles_tags_pkey PRIMARY KEY (article_id, tag_id);
ALTER TABLE ONLY public.articles_tags
    ADD CONSTRAINT  articles_tags_article_id_fk FOREIGN KEY (article_id) REFERENCES public.articles(id);
ALTER TABLE ONLY public.articles_tags
    ADD CONSTRAINT articles_tags_tag_id_fk FOREIGN KEY (tag_id) REFERENCES public.tags(id);

--
-- Name: articles_users; Type: TABLE; Schema: public;
--

CREATE TABLE public.articles_users (
    user_id bigint NOT NULL,
    article_id bigint NOT NULL
);
ALTER TABLE ONLY public.articles_users
    ADD CONSTRAINT articles_users_pkey PRIMARY KEY (article_id, user_id);
ALTER TABLE ONLY public.articles_users
    ADD CONSTRAINT articles_users_article_id_fk FOREIGN KEY (article_id) REFERENCES public.articles(id);
ALTER TABLE ONLY public.articles_users
    ADD CONSTRAINT articles_users_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);

--
-- Name: comments; Type: TABLE; Schema: public;
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    body character varying(255),
    createdat timestamp without time zone,
    updatedat timestamp without time zone,
    article_id bigint NOT NULL,
    author_id bigint NOT NULL
);
ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_author_id_fk FOREIGN KEY (author_id) REFERENCES public.users(id);
ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_article_id_fk FOREIGN KEY (article_id) REFERENCES public.articles(id);
