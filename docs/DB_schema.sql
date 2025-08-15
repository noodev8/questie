--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 17.1

-- Started on 2025-08-15 14:19:23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: questie_prod_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO questie_prod_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 234 (class 1259 OID 20596)
-- Name: app_config; Type: TABLE; Schema: public; Owner: questie_prod_user
--

CREATE TABLE public.app_config (
    id integer NOT NULL,
    config_key character varying(100) NOT NULL,
    config_value text,
    description text,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.app_config OWNER TO questie_prod_user;

--
-- TOC entry 233 (class 1259 OID 20595)
-- Name: app_config_id_seq; Type: SEQUENCE; Schema: public; Owner: questie_prod_user
--

CREATE SEQUENCE public.app_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.app_config_id_seq OWNER TO questie_prod_user;

--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 233
-- Name: app_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: questie_prod_user
--

ALTER SEQUENCE public.app_config_id_seq OWNED BY public.app_config.id;


--
-- TOC entry 216 (class 1259 OID 20464)
-- Name: app_user; Type: TABLE; Schema: public; Owner: questie_prod_user
--

CREATE TABLE public.app_user (
    id integer NOT NULL,
    email character varying(255),
    phone character varying(20),
    display_name character varying(100),
    password_hash character varying(255),
    is_anonymous boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    last_active_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    email_verified boolean DEFAULT false,
    auth_token character varying(255),
    auth_token_expires timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.app_user OWNER TO questie_prod_user;

--
-- TOC entry 215 (class 1259 OID 20463)
-- Name: app_user_id_seq; Type: SEQUENCE; Schema: public; Owner: questie_prod_user
--

CREATE SEQUENCE public.app_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.app_user_id_seq OWNER TO questie_prod_user;

--
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 215
-- Name: app_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: questie_prod_user
--

ALTER SEQUENCE public.app_user_id_seq OWNED BY public.app_user.id;


--
-- TOC entry 226 (class 1259 OID 20542)
-- Name: badge; Type: TABLE; Schema: public; Owner: questie_prod_user
--

CREATE TABLE public.badge (
    id integer NOT NULL,
    category_id integer,
    name character varying(100) NOT NULL,
    description text,
    icon character varying(10),
    requirement_type character varying(50) NOT NULL,
    requirement_value integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.badge OWNER TO questie_prod_user;

--
-- TOC entry 225 (class 1259 OID 20541)
-- Name: badge_id_seq; Type: SEQUENCE; Schema: public; Owner: questie_prod_user
--

CREATE SEQUENCE public.badge_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.badge_id_seq OWNER TO questie_prod_user;

--
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 225
-- Name: badge_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: questie_prod_user
--

ALTER SEQUENCE public.badge_id_seq OWNED BY public.badge.id;


--
-- TOC entry 220 (class 1259 OID 20495)
-- Name: quest; Type: TABLE; Schema: public; Owner: questie_prod_user
--

CREATE TABLE public.quest (
    id integer NOT NULL,
    category_id integer,
    title character varying(255) NOT NULL,
    description text,
    difficulty_level character varying(20) NOT NULL,
    points integer DEFAULT 0,
    estimated_duration_minutes integer,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.quest OWNER TO questie_prod_user;

--
-- TOC entry 218 (class 1259 OID 20482)
-- Name: quest_category; Type: TABLE; Schema: public; Owner: questie_prod_user
--

CREATE TABLE public.quest_category (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.quest_category OWNER TO questie_prod_user;

--
-- TOC entry 217 (class 1259 OID 20481)
-- Name: quest_category_id_seq; Type: SEQUENCE; Schema: public; Owner: questie_prod_user
--

CREATE SEQUENCE public.quest_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quest_category_id_seq OWNER TO questie_prod_user;

--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 217
-- Name: quest_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: questie_prod_user
--

ALTER SEQUENCE public.quest_category_id_seq OWNED BY public.quest_category.id;


--
-- TOC entry 219 (class 1259 OID 20494)
-- Name: quest_id_seq; Type: SEQUENCE; Schema: public; Owner: questie_prod_user
--

CREATE SEQUENCE public.quest_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quest_id_seq OWNER TO questie_prod_user;

--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 219
-- Name: quest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: questie_prod_user
--

ALTER SEQUENCE public.quest_id_seq OWNED BY public.quest.id;


--
-- TOC entry 228 (class 1259 OID 20554)
-- Name: user_badge; Type: TABLE; Schema: public; Owner: questie_prod_user
--

CREATE TABLE public.user_badge (
    id integer NOT NULL,
    user_id integer,
    badge_id integer,
    earned_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    progress_value integer DEFAULT 0,
    is_completed boolean DEFAULT false
);


ALTER TABLE public.user_badge OWNER TO questie_prod_user;

--
-- TOC entry 227 (class 1259 OID 20553)
-- Name: user_badge_id_seq; Type: SEQUENCE; Schema: public; Owner: questie_prod_user
--

CREATE SEQUENCE public.user_badge_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_badge_id_seq OWNER TO questie_prod_user;

--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 227
-- Name: user_badge_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: questie_prod_user
--

ALTER SEQUENCE public.user_badge_id_seq OWNED BY public.user_badge.id;


--
-- TOC entry 232 (class 1259 OID 20583)
-- Name: user_daily_activity; Type: TABLE; Schema: public; Owner: questie_prod_user
--

CREATE TABLE public.user_daily_activity (
    id integer NOT NULL,
    user_id integer,
    activity_date date NOT NULL,
    quests_completed integer DEFAULT 0,
    points_earned integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_daily_activity OWNER TO questie_prod_user;

--
-- TOC entry 231 (class 1259 OID 20582)
-- Name: user_daily_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: questie_prod_user
--

CREATE SEQUENCE public.user_daily_activity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_daily_activity_id_seq OWNER TO questie_prod_user;

--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 231
-- Name: user_daily_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: questie_prod_user
--

ALTER SEQUENCE public.user_daily_activity_id_seq OWNED BY public.user_daily_activity.id;


--
-- TOC entry 222 (class 1259 OID 20512)
-- Name: user_quest_assignment; Type: TABLE; Schema: public; Owner: questie_prod_user
--

CREATE TABLE public.user_quest_assignment (
    id integer NOT NULL,
    user_id integer,
    quest_id integer,
    assignment_type character varying(20) NOT NULL,
    assigned_date date NOT NULL,
    expires_at timestamp with time zone,
    is_completed boolean DEFAULT false,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_quest_assignment OWNER TO questie_prod_user;

--
-- TOC entry 221 (class 1259 OID 20511)
-- Name: user_quest_assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: questie_prod_user
--

CREATE SEQUENCE public.user_quest_assignment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_quest_assignment_id_seq OWNER TO questie_prod_user;

--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 221
-- Name: user_quest_assignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: questie_prod_user
--

ALTER SEQUENCE public.user_quest_assignment_id_seq OWNED BY public.user_quest_assignment.id;


--
-- TOC entry 224 (class 1259 OID 20527)
-- Name: user_quest_completion; Type: TABLE; Schema: public; Owner: questie_prod_user
--

CREATE TABLE public.user_quest_completion (
    id integer NOT NULL,
    user_id integer,
    quest_id integer,
    assignment_id integer,
    completion_notes text,
    points_earned integer DEFAULT 0,
    completed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_quest_completion OWNER TO questie_prod_user;

--
-- TOC entry 223 (class 1259 OID 20526)
-- Name: user_quest_completion_id_seq; Type: SEQUENCE; Schema: public; Owner: questie_prod_user
--

CREATE SEQUENCE public.user_quest_completion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_quest_completion_id_seq OWNER TO questie_prod_user;

--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 223
-- Name: user_quest_completion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: questie_prod_user
--

ALTER SEQUENCE public.user_quest_completion_id_seq OWNED BY public.user_quest_completion.id;


--
-- TOC entry 230 (class 1259 OID 20568)
-- Name: user_stats; Type: TABLE; Schema: public; Owner: questie_prod_user
--

CREATE TABLE public.user_stats (
    id integer NOT NULL,
    user_id integer,
    total_quests_completed integer DEFAULT 0,
    total_points integer DEFAULT 0,
    current_streak_days integer DEFAULT 0,
    longest_streak_days integer DEFAULT 0,
    last_quest_completed_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_stats OWNER TO questie_prod_user;

--
-- TOC entry 229 (class 1259 OID 20567)
-- Name: user_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: questie_prod_user
--

CREATE SEQUENCE public.user_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_stats_id_seq OWNER TO questie_prod_user;

--
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 229
-- Name: user_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: questie_prod_user
--

ALTER SEQUENCE public.user_stats_id_seq OWNED BY public.user_stats.id;


--
-- TOC entry 3332 (class 2604 OID 20599)
-- Name: app_config id; Type: DEFAULT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.app_config ALTER COLUMN id SET DEFAULT nextval('public.app_config_id_seq'::regclass);


--
-- TOC entry 3296 (class 2604 OID 20467)
-- Name: app_user id; Type: DEFAULT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.app_user ALTER COLUMN id SET DEFAULT nextval('public.app_user_id_seq'::regclass);


--
-- TOC entry 3316 (class 2604 OID 20545)
-- Name: badge id; Type: DEFAULT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.badge ALTER COLUMN id SET DEFAULT nextval('public.badge_id_seq'::regclass);


--
-- TOC entry 3305 (class 2604 OID 20498)
-- Name: quest id; Type: DEFAULT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.quest ALTER COLUMN id SET DEFAULT nextval('public.quest_id_seq'::regclass);


--
-- TOC entry 3302 (class 2604 OID 20485)
-- Name: quest_category id; Type: DEFAULT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.quest_category ALTER COLUMN id SET DEFAULT nextval('public.quest_category_id_seq'::regclass);


--
-- TOC entry 3318 (class 2604 OID 20557)
-- Name: user_badge id; Type: DEFAULT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.user_badge ALTER COLUMN id SET DEFAULT nextval('public.user_badge_id_seq'::regclass);


--
-- TOC entry 3328 (class 2604 OID 20586)
-- Name: user_daily_activity id; Type: DEFAULT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.user_daily_activity ALTER COLUMN id SET DEFAULT nextval('public.user_daily_activity_id_seq'::regclass);


--
-- TOC entry 3310 (class 2604 OID 20515)
-- Name: user_quest_assignment id; Type: DEFAULT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.user_quest_assignment ALTER COLUMN id SET DEFAULT nextval('public.user_quest_assignment_id_seq'::regclass);


--
-- TOC entry 3313 (class 2604 OID 20530)
-- Name: user_quest_completion id; Type: DEFAULT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.user_quest_completion ALTER COLUMN id SET DEFAULT nextval('public.user_quest_completion_id_seq'::regclass);


--
-- TOC entry 3322 (class 2604 OID 20571)
-- Name: user_stats id; Type: DEFAULT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.user_stats ALTER COLUMN id SET DEFAULT nextval('public.user_stats_id_seq'::regclass);


--
-- TOC entry 3385 (class 2606 OID 20604)
-- Name: app_config app_config_pkey; Type: CONSTRAINT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.app_config
    ADD CONSTRAINT app_config_pkey PRIMARY KEY (id);


--
-- TOC entry 3335 (class 2606 OID 20476)
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- TOC entry 3365 (class 2606 OID 20550)
-- Name: badge badge_pkey; Type: CONSTRAINT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.badge
    ADD CONSTRAINT badge_pkey PRIMARY KEY (id);


--
-- TOC entry 3343 (class 2606 OID 20491)
-- Name: quest_category quest_category_pkey; Type: CONSTRAINT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.quest_category
    ADD CONSTRAINT quest_category_pkey PRIMARY KEY (id);


--
-- TOC entry 3349 (class 2606 OID 20506)
-- Name: quest quest_pkey; Type: CONSTRAINT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.quest
    ADD CONSTRAINT quest_pkey PRIMARY KEY (id);


--
-- TOC entry 3373 (class 2606 OID 20562)
-- Name: user_badge user_badge_pkey; Type: CONSTRAINT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.user_badge
    ADD CONSTRAINT user_badge_pkey PRIMARY KEY (id);


--
-- TOC entry 3383 (class 2606 OID 20591)
-- Name: user_daily_activity user_daily_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.user_daily_activity
    ADD CONSTRAINT user_daily_activity_pkey PRIMARY KEY (id);


--
-- TOC entry 3357 (class 2606 OID 20519)
-- Name: user_quest_assignment user_quest_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.user_quest_assignment
    ADD CONSTRAINT user_quest_assignment_pkey PRIMARY KEY (id);


--
-- TOC entry 3363 (class 2606 OID 20536)
-- Name: user_quest_completion user_quest_completion_pkey; Type: CONSTRAINT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.user_quest_completion
    ADD CONSTRAINT user_quest_completion_pkey PRIMARY KEY (id);


--
-- TOC entry 3378 (class 2606 OID 20578)
-- Name: user_stats user_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: questie_prod_user
--

ALTER TABLE ONLY public.user_stats
    ADD CONSTRAINT user_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 3386 (class 1259 OID 20605)
-- Name: idx_app_config_key; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE UNIQUE INDEX idx_app_config_key ON public.app_config USING btree (config_key);


--
-- TOC entry 3336 (class 1259 OID 20479)
-- Name: idx_app_user_auth_token; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_app_user_auth_token ON public.app_user USING btree (auth_token);


--
-- TOC entry 3337 (class 1259 OID 20477)
-- Name: idx_app_user_display_name; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_app_user_display_name ON public.app_user USING btree (display_name);


--
-- TOC entry 3338 (class 1259 OID 20478)
-- Name: idx_app_user_email; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_app_user_email ON public.app_user USING btree (email);


--
-- TOC entry 3339 (class 1259 OID 20480)
-- Name: idx_app_user_last_active; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_app_user_last_active ON public.app_user USING btree (last_active_at);


--
-- TOC entry 3366 (class 1259 OID 20551)
-- Name: idx_badge_category; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_badge_category ON public.badge USING btree (category_id);


--
-- TOC entry 3367 (class 1259 OID 20552)
-- Name: idx_badge_requirement; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_badge_requirement ON public.badge USING btree (requirement_type);


--
-- TOC entry 3358 (class 1259 OID 20539)
-- Name: idx_completion_assignment; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_completion_assignment ON public.user_quest_completion USING btree (assignment_id);


--
-- TOC entry 3359 (class 1259 OID 20540)
-- Name: idx_completion_date; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_completion_date ON public.user_quest_completion USING btree (completed_at);


--
-- TOC entry 3360 (class 1259 OID 20538)
-- Name: idx_completion_quest; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_completion_quest ON public.user_quest_completion USING btree (quest_id);


--
-- TOC entry 3361 (class 1259 OID 20537)
-- Name: idx_completion_user; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_completion_user ON public.user_quest_completion USING btree (user_id);


--
-- TOC entry 3379 (class 1259 OID 20593)
-- Name: idx_daily_activity_date; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_daily_activity_date ON public.user_daily_activity USING btree (activity_date);


--
-- TOC entry 3380 (class 1259 OID 20592)
-- Name: idx_daily_activity_user; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_daily_activity_user ON public.user_daily_activity USING btree (user_id);


--
-- TOC entry 3381 (class 1259 OID 20594)
-- Name: idx_daily_activity_user_date; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE UNIQUE INDEX idx_daily_activity_user_date ON public.user_daily_activity USING btree (user_id, activity_date);


--
-- TOC entry 3344 (class 1259 OID 20509)
-- Name: idx_quest_active; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_quest_active ON public.quest USING btree (is_active);


--
-- TOC entry 3345 (class 1259 OID 20507)
-- Name: idx_quest_category; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_quest_category ON public.quest USING btree (category_id);


--
-- TOC entry 3340 (class 1259 OID 20493)
-- Name: idx_quest_category_active; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_quest_category_active ON public.quest_category USING btree (is_active);


--
-- TOC entry 3341 (class 1259 OID 20492)
-- Name: idx_quest_category_name; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_quest_category_name ON public.quest_category USING btree (name);


--
-- TOC entry 3346 (class 1259 OID 20508)
-- Name: idx_quest_difficulty; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_quest_difficulty ON public.quest USING btree (difficulty_level);


--
-- TOC entry 3347 (class 1259 OID 20510)
-- Name: idx_quest_points; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_quest_points ON public.quest USING btree (points);


--
-- TOC entry 3368 (class 1259 OID 20564)
-- Name: idx_user_badge_badge; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_user_badge_badge ON public.user_badge USING btree (badge_id);


--
-- TOC entry 3369 (class 1259 OID 20566)
-- Name: idx_user_badge_completed; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_user_badge_completed ON public.user_badge USING btree (is_completed);


--
-- TOC entry 3370 (class 1259 OID 20565)
-- Name: idx_user_badge_earned; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_user_badge_earned ON public.user_badge USING btree (earned_at);


--
-- TOC entry 3371 (class 1259 OID 20563)
-- Name: idx_user_badge_user; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_user_badge_user ON public.user_badge USING btree (user_id);


--
-- TOC entry 3350 (class 1259 OID 20524)
-- Name: idx_user_quest_completed; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_user_quest_completed ON public.user_quest_assignment USING btree (is_completed);


--
-- TOC entry 3351 (class 1259 OID 20522)
-- Name: idx_user_quest_date; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_user_quest_date ON public.user_quest_assignment USING btree (assigned_date);


--
-- TOC entry 3352 (class 1259 OID 20525)
-- Name: idx_user_quest_expires; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_user_quest_expires ON public.user_quest_assignment USING btree (expires_at);


--
-- TOC entry 3353 (class 1259 OID 20521)
-- Name: idx_user_quest_quest; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_user_quest_quest ON public.user_quest_assignment USING btree (quest_id);


--
-- TOC entry 3354 (class 1259 OID 20523)
-- Name: idx_user_quest_type; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_user_quest_type ON public.user_quest_assignment USING btree (assignment_type);


--
-- TOC entry 3355 (class 1259 OID 20520)
-- Name: idx_user_quest_user; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_user_quest_user ON public.user_quest_assignment USING btree (user_id);


--
-- TOC entry 3374 (class 1259 OID 20581)
-- Name: idx_user_stats_points; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_user_stats_points ON public.user_stats USING btree (total_points);


--
-- TOC entry 3375 (class 1259 OID 20580)
-- Name: idx_user_stats_streak; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_user_stats_streak ON public.user_stats USING btree (current_streak_days);


--
-- TOC entry 3376 (class 1259 OID 20579)
-- Name: idx_user_stats_user; Type: INDEX; Schema: public; Owner: questie_prod_user
--

CREATE INDEX idx_user_stats_user ON public.user_stats USING btree (user_id);


--
-- TOC entry 2084 (class 826 OID 19969)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO questie_prod_user;


--
-- TOC entry 2083 (class 826 OID 19968)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO questie_prod_user;


-- Completed on 2025-08-15 14:19:26

--
-- PostgreSQL database dump complete
--

