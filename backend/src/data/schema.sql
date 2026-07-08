--
-- PostgreSQL database dump
--

\restrict oGj3RXkRgQIYY4XUclqgjA2vNGFa1f66a0rKBOFVcj9toLNDusXtGsCHK6G2Kbo

-- Dumped from database version 15.18 (Debian 15.18-0+deb12u1)
-- Dumped by pg_dump version 15.18 (Debian 15.18-0+deb12u1)

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
-- Name: ai_agent_skills; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_agent_skills (
    agent_id integer NOT NULL,
    skill_id integer NOT NULL
);


--
-- Name: ai_agent_tools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_agent_tools (
    agent_id integer NOT NULL,
    tool_id integer NOT NULL
);


--
-- Name: ai_agents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_agents (
    id integer NOT NULL,
    slug character varying(64) NOT NULL,
    name character varying(128) NOT NULL,
    description text DEFAULT ''::text,
    icon character varying(32) DEFAULT 'bot'::character varying,
    system_prompt text DEFAULT ''::text NOT NULL,
    user_prompt_template text DEFAULT ''::text NOT NULL,
    model character varying(128) DEFAULT 'gpt-4.1-mini'::character varying NOT NULL,
    temperature real DEFAULT 0.2 NOT NULL,
    max_tokens integer DEFAULT 2048 NOT NULL,
    max_iterations integer DEFAULT 10 NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at text NOT NULL,
    updated_at text NOT NULL
);


--
-- Name: ai_agents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_agents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_agents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_agents_id_seq OWNED BY public.ai_agents.id;


--
-- Name: ai_chat_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_chat_messages (
    id integer NOT NULL,
    session_id integer NOT NULL,
    role character varying(32) NOT NULL,
    content text NOT NULL,
    tool_calls jsonb,
    tool_results jsonb,
    token_usage jsonb,
    created_at text NOT NULL
);


--
-- Name: ai_chat_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_chat_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_chat_messages_id_seq OWNED BY public.ai_chat_messages.id;


--
-- Name: ai_chat_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_chat_sessions (
    id integer NOT NULL,
    agent_id integer NOT NULL,
    title character varying(256) DEFAULT 'New Chat'::character varying NOT NULL,
    created_at text NOT NULL,
    updated_at text NOT NULL,
    problem_id integer
);


--
-- Name: ai_chat_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_chat_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_chat_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_chat_sessions_id_seq OWNED BY public.ai_chat_sessions.id;


--
-- Name: ai_skills; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_skills (
    id integer NOT NULL,
    slug character varying(64) NOT NULL,
    name character varying(128) NOT NULL,
    description text DEFAULT ''::text,
    prompt_text text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at text NOT NULL
);


--
-- Name: ai_skills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_skills_id_seq OWNED BY public.ai_skills.id;


--
-- Name: ai_tools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_tools (
    id integer NOT NULL,
    slug character varying(64) NOT NULL,
    name character varying(128) NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    parameters_schema jsonb DEFAULT '{}'::jsonb NOT NULL,
    handler_type character varying(32) DEFAULT 'python_function'::character varying NOT NULL,
    handler_config jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at text NOT NULL
);


--
-- Name: ai_tools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_tools_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_tools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_tools_id_seq OWNED BY public.ai_tools.id;


--
-- Name: ai_usage_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_usage_logs (
    id integer NOT NULL,
    agent_slug character varying(64) NOT NULL,
    model character varying(128) NOT NULL,
    prompt_tokens integer DEFAULT 0 NOT NULL,
    completion_tokens integer DEFAULT 0 NOT NULL,
    total_tokens integer DEFAULT 0 NOT NULL,
    tool_calls_count integer DEFAULT 0 NOT NULL,
    duration_ms integer DEFAULT 0 NOT NULL,
    created_at text NOT NULL
);


--
-- Name: ai_usage_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ai_usage_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ai_usage_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ai_usage_logs_id_seq OWNED BY public.ai_usage_logs.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id integer NOT NULL,
    name text NOT NULL,
    name_en text DEFAULT ''::text NOT NULL,
    abbreviation text DEFAULT ''::text NOT NULL,
    created_at text NOT NULL
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: error_attributions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.error_attributions (
    id integer NOT NULL,
    submission_id integer NOT NULL,
    analysis_type text NOT NULL,
    primary_category text DEFAULT ''::text NOT NULL,
    secondary_category text DEFAULT ''::text NOT NULL,
    summary text DEFAULT ''::text NOT NULL,
    suggestion text DEFAULT ''::text NOT NULL,
    bullets_json text DEFAULT '[]'::text NOT NULL,
    line_refs_json text DEFAULT '[]'::text NOT NULL,
    execution_status text DEFAULT 'completed'::text NOT NULL,
    status_reason text DEFAULT ''::text NOT NULL,
    provider text DEFAULT ''::text NOT NULL,
    model text DEFAULT ''::text NOT NULL,
    endpoint_url text DEFAULT ''::text NOT NULL,
    raw_response_json text DEFAULT ''::text NOT NULL,
    created_at text NOT NULL
);


--
-- Name: error_attributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.error_attributions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: error_attributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.error_attributions_id_seq OWNED BY public.error_attributions.id;


--
-- Name: llm_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.llm_settings (
    id integer DEFAULT 1 NOT NULL,
    provider text NOT NULL,
    endpoint_url text NOT NULL,
    solution_model text NOT NULL,
    attribution_model text NOT NULL,
    review_model text NOT NULL,
    solution_temperature real NOT NULL,
    attribution_temperature real NOT NULL,
    review_temperature real NOT NULL,
    api_key_secret text DEFAULT ''::text NOT NULL,
    enabled integer DEFAULT 1 NOT NULL,
    updated_at text NOT NULL,
    vision_model text DEFAULT 'gpt-4.1-mini'::text NOT NULL,
    CONSTRAINT llm_settings_id_check CHECK ((id = 1))
);


--
-- Name: problem_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.problem_categories (
    id integer NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at text NOT NULL
);


--
-- Name: problem_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.problem_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: problem_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.problem_categories_id_seq OWNED BY public.problem_categories.id;


--
-- Name: problem_test_cases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.problem_test_cases (
    id integer NOT NULL,
    problem_id integer NOT NULL,
    case_type text NOT NULL,
    stdin_text text NOT NULL,
    expected_output_text text NOT NULL,
    sort_order integer NOT NULL
);


--
-- Name: problem_test_cases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.problem_test_cases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: problem_test_cases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.problem_test_cases_id_seq OWNED BY public.problem_test_cases.id;


--
-- Name: problems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.problems (
    id integer NOT NULL,
    slug text NOT NULL,
    title text NOT NULL,
    company text NOT NULL,
    difficulty text NOT NULL,
    category_slug text DEFAULT ''::text NOT NULL,
    statement_markdown text NOT NULL,
    constraints_text text NOT NULL,
    tags_json text NOT NULL,
    examples_json text NOT NULL,
    supported_languages_json text NOT NULL,
    starter_templates_json text NOT NULL,
    source_type text,
    source text DEFAULT '手工'::text NOT NULL,
    frequency text DEFAULT '中'::text NOT NULL,
    year integer,
    source_problem_id integer REFERENCES problems(id) ON DELETE SET NULL,
    source_ref text,
    external_id text,
    status text DEFAULT '未开始'::text NOT NULL,
    created_at text NOT NULL,
    updated_at text NOT NULL,
    time_limit_ms integer DEFAULT 2000 NOT NULL,
    memory_limit_kb integer DEFAULT 262144 NOT NULL,
    "position" character varying(64) DEFAULT ''::character varying NOT NULL,
    analysis_json text
);


--
-- Name: problems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.problems_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: problems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.problems_id_seq OWNED BY public.problems.id;


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    problem_id integer NOT NULL,
    language text NOT NULL,
    run_type text NOT NULL,
    code_text text NOT NULL,
    custom_input text DEFAULT ''::text NOT NULL,
    verdict text NOT NULL,
    runtime_ms integer DEFAULT 0 NOT NULL,
    memory_kb integer DEFAULT 0 NOT NULL,
    compiler_output text DEFAULT ''::text NOT NULL,
    stderr_output text DEFAULT ''::text NOT NULL,
    failed_case_index integer,
    failed_input text,
    failed_expected_output text,
    failed_actual_output text,
    case_results_json text DEFAULT '[]'::text NOT NULL,
    judge_token text,
    created_at text NOT NULL
);


--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submissions_id_seq OWNED BY public.submissions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    display_name text DEFAULT ''::text NOT NULL,
    created_at text NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: ai_agents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agents ALTER COLUMN id SET DEFAULT nextval('public.ai_agents_id_seq'::regclass);


--
-- Name: ai_chat_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chat_messages ALTER COLUMN id SET DEFAULT nextval('public.ai_chat_messages_id_seq'::regclass);


--
-- Name: ai_chat_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chat_sessions ALTER COLUMN id SET DEFAULT nextval('public.ai_chat_sessions_id_seq'::regclass);


--
-- Name: ai_skills id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_skills ALTER COLUMN id SET DEFAULT nextval('public.ai_skills_id_seq'::regclass);


--
-- Name: ai_tools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_tools ALTER COLUMN id SET DEFAULT nextval('public.ai_tools_id_seq'::regclass);


--
-- Name: ai_usage_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_usage_logs ALTER COLUMN id SET DEFAULT nextval('public.ai_usage_logs_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: error_attributions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_attributions ALTER COLUMN id SET DEFAULT nextval('public.error_attributions_id_seq'::regclass);


--
-- Name: problem_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problem_categories ALTER COLUMN id SET DEFAULT nextval('public.problem_categories_id_seq'::regclass);


--
-- Name: problem_test_cases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problem_test_cases ALTER COLUMN id SET DEFAULT nextval('public.problem_test_cases_id_seq'::regclass);


--
-- Name: problems id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problems ALTER COLUMN id SET DEFAULT nextval('public.problems_id_seq'::regclass);


--
-- Name: submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions ALTER COLUMN id SET DEFAULT nextval('public.submissions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ai_agent_skills ai_agent_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agent_skills
    ADD CONSTRAINT ai_agent_skills_pkey PRIMARY KEY (agent_id, skill_id);


--
-- Name: ai_agent_tools ai_agent_tools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agent_tools
    ADD CONSTRAINT ai_agent_tools_pkey PRIMARY KEY (agent_id, tool_id);


--
-- Name: ai_agents ai_agents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agents
    ADD CONSTRAINT ai_agents_pkey PRIMARY KEY (id);


--
-- Name: ai_agents ai_agents_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agents
    ADD CONSTRAINT ai_agents_slug_key UNIQUE (slug);


--
-- Name: ai_chat_messages ai_chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chat_messages
    ADD CONSTRAINT ai_chat_messages_pkey PRIMARY KEY (id);


--
-- Name: ai_chat_sessions ai_chat_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chat_sessions
    ADD CONSTRAINT ai_chat_sessions_pkey PRIMARY KEY (id);


--
-- Name: ai_skills ai_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_skills
    ADD CONSTRAINT ai_skills_pkey PRIMARY KEY (id);


--
-- Name: ai_skills ai_skills_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_skills
    ADD CONSTRAINT ai_skills_slug_key UNIQUE (slug);


--
-- Name: ai_tools ai_tools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_tools
    ADD CONSTRAINT ai_tools_pkey PRIMARY KEY (id);


--
-- Name: ai_tools ai_tools_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_tools
    ADD CONSTRAINT ai_tools_slug_key UNIQUE (slug);


--
-- Name: ai_usage_logs ai_usage_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_usage_logs
    ADD CONSTRAINT ai_usage_logs_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: error_attributions error_attributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_attributions
    ADD CONSTRAINT error_attributions_pkey PRIMARY KEY (id);


--
-- Name: llm_settings llm_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.llm_settings
    ADD CONSTRAINT llm_settings_pkey PRIMARY KEY (id);


--
-- Name: problem_categories problem_categories_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problem_categories
    ADD CONSTRAINT problem_categories_name_key UNIQUE (name);


--
-- Name: problem_categories problem_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problem_categories
    ADD CONSTRAINT problem_categories_pkey PRIMARY KEY (id);


--
-- Name: problem_categories problem_categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problem_categories
    ADD CONSTRAINT problem_categories_slug_key UNIQUE (slug);


--
-- Name: problem_test_cases problem_test_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problem_test_cases
    ADD CONSTRAINT problem_test_cases_pkey PRIMARY KEY (id);


--
-- Name: problems problems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problems
    ADD CONSTRAINT problems_pkey PRIMARY KEY (id);


--
-- Name: problems problems_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problems
    ADD CONSTRAINT problems_slug_key UNIQUE (slug);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: ai_agent_skills ai_agent_skills_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agent_skills
    ADD CONSTRAINT ai_agent_skills_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.ai_agents(id);


--
-- Name: ai_agent_skills ai_agent_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agent_skills
    ADD CONSTRAINT ai_agent_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.ai_skills(id);


--
-- Name: ai_agent_tools ai_agent_tools_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agent_tools
    ADD CONSTRAINT ai_agent_tools_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.ai_agents(id);


--
-- Name: ai_agent_tools ai_agent_tools_tool_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_agent_tools
    ADD CONSTRAINT ai_agent_tools_tool_id_fkey FOREIGN KEY (tool_id) REFERENCES public.ai_tools(id);


--
-- Name: ai_chat_messages ai_chat_messages_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chat_messages
    ADD CONSTRAINT ai_chat_messages_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.ai_chat_sessions(id) ON DELETE CASCADE;


--
-- Name: ai_chat_sessions ai_chat_sessions_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chat_sessions
    ADD CONSTRAINT ai_chat_sessions_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.ai_agents(id);


--
-- Name: ai_chat_sessions ai_chat_sessions_problem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_chat_sessions
    ADD CONSTRAINT ai_chat_sessions_problem_id_fkey FOREIGN KEY (problem_id) REFERENCES public.problems(id);


--
-- Name: error_attributions error_attributions_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_attributions
    ADD CONSTRAINT error_attributions_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id);


--
-- Name: problem_test_cases problem_test_cases_problem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problem_test_cases
    ADD CONSTRAINT problem_test_cases_problem_id_fkey FOREIGN KEY (problem_id) REFERENCES public.problems(id);


--
-- Name: submissions submissions_problem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_problem_id_fkey FOREIGN KEY (problem_id) REFERENCES public.problems(id);


--
-- Name: submissions submissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: training_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_plans (
    id integer NOT NULL,
    name text NOT NULL,
    plan_type text DEFAULT 'comprehensive'::text NOT NULL,
    duration_days integer DEFAULT 7 NOT NULL,
    total_problems integer DEFAULT 0 NOT NULL,
    completed_count integer DEFAULT 0 NOT NULL,
    correct_count integer DEFAULT 0 NOT NULL,
    created_at text NOT NULL,
    updated_at text NOT NULL
);

ALTER TABLE public.training_plans OWNER TO bytehunter;

CREATE SEQUENCE public.training_plans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.training_plans_id_seq OWNED BY public.training_plans.id;

ALTER TABLE ONLY public.training_plans ALTER COLUMN id SET DEFAULT nextval('public.training_plans_id_seq'::regclass);

--
-- Name: training_plan_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_plan_items (
    id integer NOT NULL,
    plan_id integer NOT NULL,
    problem_id integer NOT NULL,
    sort_order integer DEFAULT 1 NOT NULL,
    status text DEFAULT '未开始'::text NOT NULL
);

ALTER TABLE public.training_plan_items OWNER TO bytehunter;

CREATE SEQUENCE public.training_plan_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.training_plan_items_id_seq OWNED BY public.training_plan_items.id;

ALTER TABLE ONLY public.training_plan_items ALTER COLUMN id SET DEFAULT nextval('public.training_plan_items_id_seq'::regclass);

ALTER TABLE ONLY public.training_plan_items
    ADD CONSTRAINT training_plan_items_plan_id_problem_id_key UNIQUE (plan_id, problem_id);

ALTER TABLE ONLY public.training_plan_items
    ADD CONSTRAINT training_plan_items_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.training_plans(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.training_plan_items
    ADD CONSTRAINT training_plan_items_problem_id_fkey FOREIGN KEY (problem_id) REFERENCES public.problems(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict oGj3RXkRgQIYY4XUclqgjA2vNGFa1f66a0rKBOFVcj9toLNDusXtGsCHK6G2Kbo

