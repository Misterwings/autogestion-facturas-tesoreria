--
-- PostgreSQL database dump
--

\restrict whVAwnAeseSgu8Cz0B2tSaeduLHeAmsxXRinbhaOC1j5Zg1yJXKz72khB87ZzSQ

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: payment_receipts
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO payment_receipts;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: payment_receipts
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bank_payment_lines; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.bank_payment_lines (
    id bigint NOT NULL,
    payment_batch_id bigint NOT NULL,
    branch_id bigint NOT NULL,
    third_party_id bigint,
    bank_id bigint,
    payment_receipt_id bigint,
    nit character varying(255) NOT NULL,
    person_type character varying(1) NOT NULL,
    bank_account_number character varying(255) NOT NULL,
    bank_account_type character varying(2) NOT NULL,
    bank_code character varying(20) NOT NULL,
    third_party_name character varying(255),
    amount numeric(18,2) NOT NULL,
    source_sheet character varying(255) NOT NULL,
    source_row integer NOT NULL,
    has_invoice_detail boolean DEFAULT false NOT NULL,
    warnings json,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.bank_payment_lines OWNER TO payment_receipts;

--
-- Name: bank_payment_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: payment_receipts
--

CREATE SEQUENCE public.bank_payment_lines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bank_payment_lines_id_seq OWNER TO payment_receipts;

--
-- Name: bank_payment_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: payment_receipts
--

ALTER SEQUENCE public.bank_payment_lines_id_seq OWNED BY public.bank_payment_lines.id;


--
-- Name: banks; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.banks (
    id bigint NOT NULL,
    code character varying(20) NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.banks OWNER TO payment_receipts;

--
-- Name: banks_id_seq; Type: SEQUENCE; Schema: public; Owner: payment_receipts
--

CREATE SEQUENCE public.banks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.banks_id_seq OWNER TO payment_receipts;

--
-- Name: banks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: payment_receipts
--

ALTER SEQUENCE public.banks_id_seq OWNED BY public.banks.id;


--
-- Name: branches; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.branches (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.branches OWNER TO payment_receipts;

--
-- Name: branches_id_seq; Type: SEQUENCE; Schema: public; Owner: payment_receipts
--

CREATE SEQUENCE public.branches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.branches_id_seq OWNER TO payment_receipts;

--
-- Name: branches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: payment_receipts
--

ALTER SEQUENCE public.branches_id_seq OWNED BY public.branches.id;


--
-- Name: cache; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration bigint NOT NULL
);


ALTER TABLE public.cache OWNER TO payment_receipts;

--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration bigint NOT NULL
);


ALTER TABLE public.cache_locks OWNER TO payment_receipts;

--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection character varying(255) NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.failed_jobs OWNER TO payment_receipts;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: payment_receipts
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.failed_jobs_id_seq OWNER TO payment_receipts;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: payment_receipts
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: import_errors; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.import_errors (
    id bigint NOT NULL,
    payment_batch_id bigint NOT NULL,
    severity character varying(255) DEFAULT 'warning'::character varying NOT NULL,
    code character varying(255) NOT NULL,
    message text NOT NULL,
    source_sheet character varying(255),
    source_row integer,
    context json,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.import_errors OWNER TO payment_receipts;

--
-- Name: import_errors_id_seq; Type: SEQUENCE; Schema: public; Owner: payment_receipts
--

CREATE SEQUENCE public.import_errors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.import_errors_id_seq OWNER TO payment_receipts;

--
-- Name: import_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: payment_receipts
--

ALTER SEQUENCE public.import_errors_id_seq OWNED BY public.import_errors.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.invoices (
    id bigint NOT NULL,
    payment_batch_id bigint NOT NULL,
    branch_id bigint NOT NULL,
    payment_receipt_id bigint,
    third_party_id bigint,
    payment_date date,
    detail_document_number character varying(255) NOT NULL,
    third_party_name character varying(255) NOT NULL,
    support_document character varying(255) NOT NULL,
    causation_document character varying(255) NOT NULL,
    amount numeric(18,2) NOT NULL,
    concept character varying(255),
    status character varying(255) DEFAULT 'paid'::character varying NOT NULL,
    source_sheet character varying(255) NOT NULL,
    source_row integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.invoices OWNER TO payment_receipts;

--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: payment_receipts
--

CREATE SEQUENCE public.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invoices_id_seq OWNER TO payment_receipts;

--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: payment_receipts
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


ALTER TABLE public.job_batches OWNER TO payment_receipts;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


ALTER TABLE public.jobs OWNER TO payment_receipts;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: payment_receipts
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.jobs_id_seq OWNER TO payment_receipts;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: payment_receipts
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO payment_receipts;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: payment_receipts
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO payment_receipts;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: payment_receipts
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO payment_receipts;

--
-- Name: payment_batches; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.payment_batches (
    id bigint NOT NULL,
    source_file_name character varying(255) NOT NULL,
    source_file_path character varying(255),
    payment_date date,
    has_model_sheet boolean DEFAULT false NOT NULL,
    status character varying(255) DEFAULT 'imported'::character varying NOT NULL,
    bank_payment_lines_count integer DEFAULT 0 NOT NULL,
    receipts_count integer DEFAULT 0 NOT NULL,
    invoices_count integer DEFAULT 0 NOT NULL,
    bank_payment_total numeric(18,2) DEFAULT '0'::numeric NOT NULL,
    invoice_total numeric(18,2) DEFAULT '0'::numeric NOT NULL,
    bank_file_path character varying(255),
    imported_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    granada_file_path character varying(255),
    branch_file_paths json
);


ALTER TABLE public.payment_batches OWNER TO payment_receipts;

--
-- Name: payment_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: payment_receipts
--

CREATE SEQUENCE public.payment_batches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payment_batches_id_seq OWNER TO payment_receipts;

--
-- Name: payment_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: payment_receipts
--

ALTER SEQUENCE public.payment_batches_id_seq OWNED BY public.payment_batches.id;


--
-- Name: payment_receipts; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.payment_receipts (
    id bigint NOT NULL,
    payment_batch_id bigint NOT NULL,
    branch_id bigint NOT NULL,
    third_party_id bigint,
    receipt_number character varying(255) NOT NULL,
    payment_date date,
    amount numeric(18,2) NOT NULL,
    concept character varying(255),
    source_sheet character varying(255) NOT NULL,
    source_row integer NOT NULL,
    warnings json,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.payment_receipts OWNER TO payment_receipts;

--
-- Name: payment_receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: payment_receipts
--

CREATE SEQUENCE public.payment_receipts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payment_receipts_id_seq OWNER TO payment_receipts;

--
-- Name: payment_receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: payment_receipts
--

ALTER SEQUENCE public.payment_receipts_id_seq OWNED BY public.payment_receipts.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


ALTER TABLE public.sessions OWNER TO payment_receipts;

--
-- Name: third_parties; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.third_parties (
    id bigint NOT NULL,
    document_number character varying(255) NOT NULL,
    person_type character varying(1) NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    alternate_name character varying(255)
);


ALTER TABLE public.third_parties OWNER TO payment_receipts;

--
-- Name: third_parties_id_seq; Type: SEQUENCE; Schema: public; Owner: payment_receipts
--

CREATE SEQUENCE public.third_parties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.third_parties_id_seq OWNER TO payment_receipts;

--
-- Name: third_parties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: payment_receipts
--

ALTER SEQUENCE public.third_parties_id_seq OWNED BY public.third_parties.id;


--
-- Name: third_party_bank_accounts; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.third_party_bank_accounts (
    id bigint NOT NULL,
    third_party_id bigint NOT NULL,
    bank_id bigint NOT NULL,
    account_number character varying(255) NOT NULL,
    account_type character varying(2) NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.third_party_bank_accounts OWNER TO payment_receipts;

--
-- Name: third_party_bank_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: payment_receipts
--

CREATE SEQUENCE public.third_party_bank_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.third_party_bank_accounts_id_seq OWNER TO payment_receipts;

--
-- Name: third_party_bank_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: payment_receipts
--

ALTER SEQUENCE public.third_party_bank_accounts_id_seq OWNED BY public.third_party_bank_accounts.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: payment_receipts
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.users OWNER TO payment_receipts;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: payment_receipts
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO payment_receipts;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: payment_receipts
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: bank_payment_lines id; Type: DEFAULT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.bank_payment_lines ALTER COLUMN id SET DEFAULT nextval('public.bank_payment_lines_id_seq'::regclass);


--
-- Name: banks id; Type: DEFAULT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.banks ALTER COLUMN id SET DEFAULT nextval('public.banks_id_seq'::regclass);


--
-- Name: branches id; Type: DEFAULT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.branches ALTER COLUMN id SET DEFAULT nextval('public.branches_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: import_errors id; Type: DEFAULT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.import_errors ALTER COLUMN id SET DEFAULT nextval('public.import_errors_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: payment_batches id; Type: DEFAULT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.payment_batches ALTER COLUMN id SET DEFAULT nextval('public.payment_batches_id_seq'::regclass);


--
-- Name: payment_receipts id; Type: DEFAULT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.payment_receipts ALTER COLUMN id SET DEFAULT nextval('public.payment_receipts_id_seq'::regclass);


--
-- Name: third_parties id; Type: DEFAULT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.third_parties ALTER COLUMN id SET DEFAULT nextval('public.third_parties_id_seq'::regclass);


--
-- Name: third_party_bank_accounts id; Type: DEFAULT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.third_party_bank_accounts ALTER COLUMN id SET DEFAULT nextval('public.third_party_bank_accounts_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: bank_payment_lines; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.bank_payment_lines (id, payment_batch_id, branch_id, third_party_id, bank_id, payment_receipt_id, nit, person_type, bank_account_number, bank_account_type, bank_code, third_party_name, amount, source_sheet, source_row, has_invoice_detail, warnings, created_at, updated_at) FROM stdin;
14	11	10	25	7	3	9003115698	1	487003030	CA	52	AGROPECUARIA CRIADERO VILLA MARIA SAS	2950885.00	CIUDAD JARDIN	9	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
15	11	10	58	4	4	9015982943	1	1869997690	CC	51	ARMIRENE COLOMBIA SAS	198959.00	CIUDAD JARDIN	12	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
16	11	10	48	4	5	9000402990	1	35169997919	CC	51	ATLANTIC FS SAS	152796.00	CIUDAD JARDIN	14	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
17	11	10	90	5	6	901784030	1	82100007778	CA	7	BOMBA FOODS SAS	6447110.00	CIUDAD JARDIN	17	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
18	11	10	96	6	7	9002329423	1	487217820	CC	1	BONNIPLAST	834903.00	CIUDAD JARDIN	19	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
19	11	10	166	5	8	800208785	1	22903374131	CC	7	CONGELADOS AGRICOLAS SA	5477703.00	CIUDAD JARDIN	22	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
20	11	10	188	5	9	901068725	1	80880349591	CA	7	DANIEL SANCHEZ SAS	530127.00	CIUDAD JARDIN	26	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
21	11	10	209	6	10	9010913557	1	166341958	CC	1	DISTRIALIMENTOS DEL CAMPO SAS	1550250.00	CIUDAD JARDIN	28	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
22	11	10	206	4	11	8909165754	1	9020035106	CC	51	DISTRIBUIDORA DE VINOS Y LICORES SA	2150357.00	CIUDAD JARDIN	30	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
23	11	10	243	4	12	8909177802	1	38469999049	CC	51	ELECTROQUIMICA WEST S.A	984365.00	CIUDAD JARDIN	32	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
24	11	10	265	5	13	1130634913	2	81084014028	CA	7	FIGUEROA COLLAZOS FARITZA FERNANDA	102663.00	CIUDAD JARDIN	34	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
25	11	10	273	17	14	9014727523	1	21004449589	CC	32	FRUTOS Y PULPAS SAS	995000.00	CIUDAD JARDIN	36	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
26	11	10	338	5	15	830074144	1	4829183069	CA	7	GWS GLOBALWINE Y SPIRITS LTDA	5900780.00	CIUDAD JARDIN	41	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
27	11	10	328	4	16	9003385688	1	10269986476	CC	51	GRUPO EMPRESARIAL GIRALDO S S A S	1703302.00	CIUDAD JARDIN	44	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
28	11	10	329	4	17	9014331463	1	17969996002	CC	51	GRUPO GM SAS	324246.00	CIUDAD JARDIN	46	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
29	11	10	373	5	18	8909038587	1	12610660873	CC	7	INDUSTRIA NACIONAL DE GASEOSAS SA	3226927.00	CIUDAD JARDIN	48	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
30	11	10	390	17	19	9004225949	1	24143066996	CA	32	INVERSIONES VIVE AGRO S.A.S	904000.00	CIUDAD JARDIN	50	t	\N	2026-07-24 15:28:31	2026-07-24 15:28:31
31	11	10	537	5	20	800190654	1	6007487112	CC	7	PAPELERIA LOS COLORES SAS	921445.00	CIUDAD JARDIN	52	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
32	11	10	549	5	21	900964881	1	26500006518	CA	7	PARROQUIA NUESTRA SEÑORA DE LA RECONCILI	200000.00	CIUDAD JARDIN	54	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
33	11	10	293	6	22	8909039395	1	226431963	CA	1	POSTOBON SA	82000.00	CIUDAD JARDIN	56	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
34	11	10	186	5	23	51959168	2	62179643117	CA	7	RONCANCIO VELOSA CLAUDIA PATRICIA	303810.00	CIUDAD JARDIN	58	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
35	11	10	630	5	24	900458352	1	82966006737	CC	7	SALUD ABLE FOODS SAS	66240.00	CIUDAD JARDIN	60	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
36	11	10	664	5	25	9011767911	1	75093137477	CA	7	SOGNI FOODS SAS	190553.00	CIUDAD JARDIN	62	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
37	11	10	740	4	26	8600341187	1	550009500057451	CA	51	VILASECA S.A.S.	748156.00	CIUDAD JARDIN	64	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
38	11	11	25	7	27	9003115698	1	487003030	CA	52	AGROPECUARIA CRIADERO VILLA MARIA SAS	2343665.00	UNICENTRO	9	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
39	11	11	48	4	28	9000402990	1	35169997919	CC	51	ATLANTIC FS SAS	101864.00	UNICENTRO	11	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
40	11	11	90	5	29	901784030	1	82100007778	CA	7	BOMBA FOODS SAS	2601288.00	UNICENTRO	13	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
41	11	11	145	4	30	8000273749	1	9022308488	CA	51	CI TECNOLOGIA ALIMENTARIA SA TALSA	431248.00	UNICENTRO	15	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
42	11	11	166	5	31	800208785	1	22903374131	CC	7	CONGELADOS AGRICOLAS SA	1969949.00	UNICENTRO	18	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
43	11	11	188	5	32	901068725	1	80880349591	CA	7	DANIEL SANCHEZ SAS	23000.00	UNICENTRO	20	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
44	11	11	209	6	33	9010913557	1	166341958	CC	1	DISTRIALIMENTOS DEL CAMPO SAS	1582425.00	UNICENTRO	22	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
45	11	11	265	5	34	1130634913	2	81084014028	CA	7	FIGUEROA COLLAZOS FARITZA FERNANDA	869801.00	UNICENTRO	28	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
46	11	11	273	17	35	9014727523	1	21004449589	CC	32	FRUTOS Y PULPAS SAS	550000.00	UNICENTRO	30	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
47	11	11	328	4	36	9003385688	1	10269986476	CC	51	GRUPO EMPRESARIAL GIRALDO S S A S	727100.00	UNICENTRO	33	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
48	11	11	329	4	37	9014331463	1	17969996002	CC	51	GRUPO GM SAS	321288.00	UNICENTRO	35	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
49	11	11	330	5	38	901286481	1	86000011801	CC	7	GRUPO HELPPO SAS	1526056.00	UNICENTRO	38	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
50	11	11	373	5	39	8909038587	1	12610660873	CC	7	INDUSTRIA NACIONAL DE GASEOSAS SA	2772360.00	UNICENTRO	40	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
51	11	11	390	17	40	9004225949	1	24143066996	CA	32	INVERSIONES VIVE AGRO S.A.S	1122800.00	UNICENTRO	44	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
52	11	11	404	5	41	8903116257	1	6031162502	CC	7	KOLBITOS S A S	211500.00	UNICENTRO	50	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
53	11	11	421	5	42	900985954	1	82962710990	CC	7	LE GRAND FRANCES SAS	238380.00	UNICENTRO	54	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
54	11	11	537	5	43	800190654	1	6007487112	CC	7	PAPELERIA LOS COLORES SAS	930722.00	UNICENTRO	57	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
55	11	11	293	6	44	8909039395	1	226431963	CA	1	POSTOBON SA	163999.00	UNICENTRO	59	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
56	11	11	186	5	45	51959168	2	62179643117	CA	7	RONCANCIO VELOSA CLAUDIA PATRICIA	151905.00	UNICENTRO	61	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
57	11	11	664	5	46	9011767911	1	75093137477	CA	7	SOGNI FOODS SAS	119095.00	UNICENTRO	63	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
58	11	11	735	4	47	1144192780	2	550488417596092	CA	51	VICUÑA GOMEZ JESSIE	1638137.00	UNICENTRO	65	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
59	11	11	740	4	48	8600341187	1	550009500057451	CA	51	VILASECA S.A.S.	1292655.00	UNICENTRO	67	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
60	11	12	25	7	49	9003115698	1	487003030	CA	52	AGROPECUARIA CRIADERO VILLA MARIA SAS	907835.00	JARDIN PLAZA	9	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
61	11	12	48	4	50	9000402990	1	35169997919	CC	51	ATLANTIC FS SAS	203728.00	JARDIN PLAZA	11	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
62	11	12	90	5	51	901784030	1	82100007778	CA	7	BOMBA FOODS SAS	474155.00	JARDIN PLAZA	13	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
63	11	12	96	6	52	9002329423	1	487217820	CC	1	BONNIPLAST	706313.00	JARDIN PLAZA	16	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
64	11	12	166	5	53	800208785	1	22903374131	CC	7	CONGELADOS AGRICOLAS SA	5353703.00	JARDIN PLAZA	19	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
65	11	12	188	5	54	901068725	1	80880349591	CA	7	DANIEL SANCHEZ SAS	127346.00	JARDIN PLAZA	22	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
66	11	12	206	4	55	8909165754	1	9020035106	CC	51	DISTRIBUIDORA DE VINOS Y LICORES SA	1106988.00	JARDIN PLAZA	24	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
67	11	12	243	4	56	8909177802	1	38469999049	CC	51	ELECTROQUIMICA WEST S.A	341408.00	JARDIN PLAZA	27	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
68	11	12	265	5	57	1130634913	2	81084014028	CA	7	FIGUEROA COLLAZOS FARITZA FERNANDA	89546.00	JARDIN PLAZA	30	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
69	11	12	273	17	58	9014727523	1	21004449589	CC	32	FRUTOS Y PULPAS SAS	486000.00	JARDIN PLAZA	32	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
70	11	12	338	5	59	830074144	1	4829183069	CA	7	GWS GLOBALWINE Y SPIRITS LTDA	62454.00	JARDIN PLAZA	34	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
71	11	12	328	4	60	9003385688	1	10269986476	CC	51	GRUPO EMPRESARIAL GIRALDO S S A S	390400.00	JARDIN PLAZA	38	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
72	11	12	329	4	61	9014331463	1	17969996002	CC	51	GRUPO GM SAS	241640.00	JARDIN PLAZA	40	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
73	11	12	330	5	62	901286481	1	86000011801	CC	7	GRUPO HELPPO SAS	1014394.00	JARDIN PLAZA	45	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
74	11	12	373	5	63	8909038587	1	12610660873	CC	7	INDUSTRIA NACIONAL DE GASEOSAS SA	2284436.00	JARDIN PLAZA	47	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
75	11	12	390	17	64	9004225949	1	24143066996	CA	32	INVERSIONES VIVE AGRO S.A.S	1601000.00	JARDIN PLAZA	51	t	\N	2026-07-24 15:28:32	2026-07-24 15:28:32
76	11	12	266	4	65	25233450	2	470160032780	CC	51	JARAMILLO HURTADO CLAUDIA	293494.00	JARDIN PLAZA	53	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
77	11	12	404	5	66	8903116257	1	6031162502	CC	7	KOLBITOS S A S	211500.00	JARDIN PLAZA	59	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
78	11	12	421	5	67	900985954	1	82962710990	CC	7	LE GRAND FRANCES SAS	82200.00	JARDIN PLAZA	61	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
79	11	12	537	5	68	800190654	1	6007487112	CC	7	PAPELERIA LOS COLORES SAS	1074122.00	JARDIN PLAZA	63	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
80	11	12	626	5	69	901006683	1	71072402716	CC	7	SACOTTO - CAGIGAS S.A.S.	153227.00	JARDIN PLAZA	65	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
81	11	12	735	4	70	1144192780	2	550488417596092	CA	51	VICUÑA GOMEZ JESSIE	879125.00	JARDIN PLAZA	67	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
82	11	12	740	4	71	8600341187	1	550009500057451	CA	51	VILASECA S.A.S.	595686.00	JARDIN PLAZA	69	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
83	11	13	25	7	72	9003115698	1	487003030	CA	52	AGROPECUARIA CRIADERO VILLA MARIA SAS	5802374.00	PANCE	9	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
84	11	13	58	4	73	9015982943	1	1869997690	CC	51	ARMIRENE COLOMBIA SAS	644235.00	PANCE	12	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
85	11	13	90	5	74	901784030	1	82100007778	CA	7	BOMBA FOODS SAS	2611987.00	PANCE	15	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
86	11	13	96	6	75	9002329423	1	487217820	CC	1	BONNIPLAST	1065352.00	PANCE	18	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
87	11	13	164	5	76	8600002616	1	17157157600	CC	7	COMPANIA NACIONAL DE LEVADURAS LEVAPAN S	206162.00	PANCE	20	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
88	11	13	166	5	77	800208785	1	22903374131	CC	7	CONGELADOS AGRICOLAS SA	1478544.00	PANCE	23	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
89	11	13	209	6	78	9010913557	1	166341958	CC	1	DISTRIALIMENTOS DEL CAMPO SAS	1830075.00	PANCE	25	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
90	11	13	206	4	79	8909165754	1	9020035106	CC	51	DISTRIBUIDORA DE VINOS Y LICORES SA	2151123.00	PANCE	28	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
91	11	13	211	4	80	8050107523	1	17969999352	CC	51	DISTRIBUIDORA LA COSTA SA	236566.00	PANCE	30	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
92	11	13	243	4	81	8909177802	1	38469999049	CC	51	ELECTROQUIMICA WEST S.A	662647.00	PANCE	32	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
93	11	13	257	9	82	8000655675	1	1208073	CC	23	FABRICA DE ALIMENTOS PROCESADOS VENTOLINI SA	280002.00	PANCE	34	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
94	11	13	265	5	83	1130634913	2	81084014028	CA	7	FIGUEROA COLLAZOS FARITZA FERNANDA	920813.00	PANCE	39	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
95	11	13	273	17	84	9014727523	1	21004449589	CC	32	FRUTOS Y PULPAS SAS	550000.00	PANCE	42	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
96	11	13	328	4	85	9003385688	1	10269986476	CC	51	GRUPO EMPRESARIAL GIRALDO S S A S	738302.00	PANCE	45	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
97	11	13	329	4	86	9014331463	1	17969996002	CC	51	GRUPO GM SAS	199720.00	PANCE	47	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
98	11	13	330	5	87	901286481	1	86000011801	CC	7	GRUPO HELPPO SAS	963761.00	PANCE	49	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
99	11	13	373	5	88	8909038587	1	12610660873	CC	7	INDUSTRIA NACIONAL DE GASEOSAS SA	3116398.00	PANCE	52	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
100	11	13	390	17	89	9004225949	1	24143066996	CA	32	INVERSIONES VIVE AGRO S.A.S	813600.00	PANCE	54	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
101	11	13	404	5	90	8903116257	1	6031162502	CC	7	KOLBITOS S A S	135000.00	PANCE	57	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
102	11	13	421	5	91	900985954	1	82962710990	CC	7	LE GRAND FRANCES SAS	197280.00	PANCE	60	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
103	11	13	537	5	92	800190654	1	6007487112	CC	7	PAPELERIA LOS COLORES SAS	938136.00	PANCE	62	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
104	11	13	186	5	93	51959168	2	62179643117	CA	7	RONCANCIO VELOSA CLAUDIA PATRICIA	303810.00	PANCE	64	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
105	11	13	630	5	94	900458352	1	82966006737	CC	7	SALUD ABLE FOODS SAS	58080.00	PANCE	66	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
106	11	13	664	5	95	9011767911	1	75093137477	CA	7	SOGNI FOODS SAS	142914.00	PANCE	68	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
107	11	13	735	4	96	1144192780	2	550488417596092	CA	51	VICUÑA GOMEZ JESSIE	1445663.00	PANCE	70	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
108	11	13	740	4	97	8600341187	1	550009500057451	CA	51	VILASECA S.A.S.	473314.00	PANCE	72	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
109	11	14	25	7	98	9003115698	1	487003030	CA	52	AGROPECUARIA CRIADERO VILLA MARIA SAS	294806.00	BOCHALEMA	8	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
110	11	14	58	4	99	9015982943	1	1869997690	CC	51	ARMIRENE COLOMBIA SAS	1423606.00	BOCHALEMA	11	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
111	11	14	48	4	100	9000402990	1	35169997919	CC	51	ATLANTIC FS SAS	190995.00	BOCHALEMA	13	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
112	11	14	90	5	101	901784030	1	82100007778	CA	7	BOMBA FOODS SAS	2920655.00	BOCHALEMA	15	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
113	11	14	166	5	102	800208785	1	22903374131	CC	7	CONGELADOS AGRICOLAS SA	3960777.00	BOCHALEMA	17	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
114	11	14	188	5	103	901068725	1	80880349591	CA	7	DANIEL SANCHEZ SAS	575536.00	BOCHALEMA	21	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
115	11	14	209	6	104	9010913557	1	166341958	CC	1	DISTRIALIMENTOS DEL CAMPO SAS	1054950.00	BOCHALEMA	23	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
116	11	14	206	4	105	8909165754	1	9020035106	CC	51	DISTRIBUIDORA DE VINOS Y LICORES SA	1508343.00	BOCHALEMA	26	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
117	11	14	243	4	106	8909177802	1	38469999049	CC	51	ELECTROQUIMICA WEST S.A	1360636.00	BOCHALEMA	28	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
118	11	14	273	17	107	9014727523	1	21004449589	CC	32	FRUTOS Y PULPAS SAS	468000.00	BOCHALEMA	30	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
119	11	14	328	4	108	9003385688	1	10269986476	CC	51	GRUPO EMPRESARIAL GIRALDO S S A S	944000.00	BOCHALEMA	33	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
120	11	14	329	4	109	9014331463	1	17969996002	CC	51	GRUPO GM SAS	331012.00	BOCHALEMA	36	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
121	11	14	330	5	110	901286481	1	86000011801	CC	7	GRUPO HELPPO SAS	1370294.00	BOCHALEMA	40	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
122	11	14	373	5	111	8909038587	1	12610660873	CC	7	INDUSTRIA NACIONAL DE GASEOSAS SA	2257502.00	BOCHALEMA	43	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
123	11	14	390	17	112	9004225949	1	24143066996	CA	32	INVERSIONES VIVE AGRO S.A.S	901600.00	BOCHALEMA	46	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
124	11	14	404	5	113	8903116257	1	6031162502	CC	7	KOLBITOS S A S	139500.00	BOCHALEMA	50	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
125	11	14	421	5	114	900985954	1	82962710990	CC	7	LE GRAND FRANCES SAS	98640.00	BOCHALEMA	52	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
126	11	14	537	5	115	800190654	1	6007487112	CC	7	PAPELERIA LOS COLORES SAS	1901816.00	BOCHALEMA	55	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
127	11	14	570	5	116	900319753	1	65284955984	CC	7	PRICESMART COLOMBIA SAS	544200.00	BOCHALEMA	57	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
128	11	14	626	5	117	901006683	1	71072402716	CC	7	SACOTTO - CAGIGAS S.A.S.	64200.00	BOCHALEMA	59	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
129	11	14	630	5	118	900458352	1	82966006737	CC	7	SALUD ABLE FOODS SAS	34080.00	BOCHALEMA	61	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
130	11	14	601	7	119	16630920	2	102926073	CA	52	REFRIGERACION VALDES	216600.00	BOCHALEMA	63	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
131	11	14	735	4	120	1144192780	2	550488417596092	CA	51	VICUÑA GOMEZ JESSIE	1950419.00	BOCHALEMA	65	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
132	11	14	740	4	121	8600341187	1	550009500057451	CA	51	VILASECA S.A.S.	601965.00	BOCHALEMA	67	t	\N	2026-07-24 15:28:33	2026-07-24 15:28:33
133	11	15	126	4	122	31241805	2	17570071864	CA	51	CARRILLO ROMELIA	1317213.00	OFICINA	8	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
134	11	15	176	4	123	31474203	2	488407287272	CA	51	CORDOBA CAICEDO MARGOT MARIA	650000.00	OFICINA	10	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
135	11	15	10	4	124	79343931	2	16090296928	CA	51	DIAZ CHAVEZ FRANCISCO AURELIO	6382970.00	OFICINA	13	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
136	11	15	308	15	125	94043632	2	875003357	CA	13	GOMEZ RAMIREZ ANDRES FELIPE	50000.00	OFICINA	16	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
137	11	15	468	5	126	16799759	2	83679322071	CA	7	MEJIA FALLA VICTOR HUGO	3512957.00	OFICINA	19	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
138	11	16	292	14	127	16720297	2	5842000688	CA	19	GARRIDO RENGIFO ALBERTO	577065.00	MERCADEO	8	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
139	11	16	758	6	128	1005744761	2	475139473	CA	1	OTERO ALBARRACIN SALVATORE	350001.00	MERCADEO	10	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
140	11	16	554	5	129	1105362513	2	75024905616	CA	7	PERDOMO CLAVIJO SANTIAGO	900000.00	MERCADEO	12	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
141	11	16	747	5	130	66835978	2	6200000997	CA	7	YEPES YEPES CLAUDIA	86215.00	MERCADEO	16	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
142	11	17	25	7	131	9003115698	1	487003030	CA	52	AGROPECUARIA CRIADERO VILLA MARIA SAS	2814946.00	GRANADA	9	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
143	11	17	48	4	132	9000402990	1	35169997919	CC	51	ATLANTIC FS SAS	127925.00	GRANADA	11	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
144	11	17	90	5	133	901784030	1	82100007778	CA	7	BOMBA FOODS SAS	3236370.00	GRANADA	14	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
145	11	17	96	6	134	9002329423	1	487217820	CC	1	BONNIPLAST	568744.00	GRANADA	17	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
146	11	17	112	7	135	890303093	1	165004110	CA	52	CAJA DE COMPENSACION FAMILIAR DEL VALLE	696045.00	GRANADA	19	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
147	11	17	166	5	136	800208785	1	22903374131	CC	7	CONGELADOS AGRICOLAS SA	1586515.00	GRANADA	21	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
148	11	17	188	5	137	901068725	1	80880349591	CA	7	DANIEL SANCHEZ SAS	321601.00	GRANADA	24	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
149	11	17	209	6	138	9010913557	1	166341958	CC	1	DISTRIALIMENTOS DEL CAMPO SAS	1604850.00	GRANADA	27	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
150	11	17	206	4	139	8909165754	1	9020035106	CC	51	DISTRIBUIDORA DE VINOS Y LICORES SA	2496612.00	GRANADA	30	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
151	11	17	243	4	140	8909177802	1	38469999049	CC	51	ELECTROQUIMICA WEST S.A	470424.00	GRANADA	32	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
152	11	17	257	9	141	8000655675	1	1208073	CC	23	FABRICA DE ALIMENTOS PROCESADOS VENTOLINI SA	140001.00	GRANADA	34	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
153	11	17	273	17	142	9014727523	1	21004449589	CC	32	FRUTOS Y PULPAS SAS	665000.00	GRANADA	36	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
154	11	17	328	4	143	9003385688	1	10269986476	CC	51	GRUPO EMPRESARIAL GIRALDO S S A S	1344603.00	GRANADA	40	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
155	11	17	329	4	144	9014331463	1	17969996002	CC	51	GRUPO GM SAS	201816.00	GRANADA	42	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
156	11	17	330	5	145	901286481	1	86000011801	CC	7	GRUPO HELPPO SAS	1356257.00	GRANADA	46	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
157	11	17	373	5	146	8909038587	1	12610660873	CC	7	INDUSTRIA NACIONAL DE GASEOSAS SA	3006389.00	GRANADA	48	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
158	11	17	390	17	147	9004225949	1	24143066996	CA	32	INVERSIONES VIVE AGRO S.A.S	1118000.00	GRANADA	51	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
159	11	17	266	4	148	25233450	2	470160032780	CC	51	JARAMILLO HURTADO CLAUDIA	149583.00	GRANADA	53	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
160	11	17	421	5	149	900985954	1	82962710990	CC	7	LE GRAND FRANCES SAS	164400.00	GRANADA	56	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
161	11	17	469	5	150	94421793	2	81000016934	CA	7	MERA ROSERO OSCAR	252986.00	GRANADA	61	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
162	11	17	537	5	151	800190654	1	6007487112	CC	7	PAPELERIA LOS COLORES SAS	305868.00	GRANADA	63	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
163	11	17	293	6	152	8909039395	1	226431963	CA	1	POSTOBON SA	616800.00	GRANADA	65	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
164	11	17	664	5	153	9011767911	1	75093137477	CA	7	SOGNI FOODS SAS	119095.00	GRANADA	67	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
165	11	17	681	4	154	8600000064	1	6500243651	CA	51	TEAM FOODS COLOMBIA S.A.	1252370.00	GRANADA	69	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
166	11	17	696	5	155	890935900	1	2993590005	CA	7	TOSTADITOS SUSANITA SAS	104400.00	GRANADA	71	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
167	11	17	735	4	156	1144192780	2	550488417596092	CA	51	VICUÑA GOMEZ JESSIE	1392286.00	GRANADA	73	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
168	11	17	740	4	157	8600341187	1	550009500057451	CA	51	VILASECA S.A.S.	323175.00	GRANADA	75	t	\N	2026-07-24 15:28:34	2026-07-24 15:28:34
\.


--
-- Data for Name: banks; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.banks (id, code, name, created_at, updated_at) FROM stdin;
4	51	DAVIVIENDA	2026-07-24 13:43:05	2026-07-24 13:43:05
5	7	BANCOLOMBIA	2026-07-24 13:43:14	2026-07-24 13:43:14
6	1	B/BOGOTA	2026-07-24 13:43:14	2026-07-24 13:43:14
7	52	AV VILLAS	2026-07-24 13:43:14	2026-07-24 13:43:14
8	507	NEQUI	2026-07-24 13:43:14	2026-07-24 13:43:14
9	23	B/OCCIDENTE	2026-07-24 13:43:14	2026-07-24 13:43:14
10	6	BANCO ITAU	2026-07-24 13:43:14	2026-07-24 13:43:14
11	9	CITIBANK	2026-07-24 13:43:14	2026-07-24 13:43:14
12	60	B/PICHINCHA	2026-07-24 13:43:14	2026-07-24 13:43:14
13	61	BANCO COOMEVA	2026-07-24 13:43:14	2026-07-24 13:43:14
14	19	COLPATRIA	2026-07-24 13:43:15	2026-07-24 13:43:15
15	13	BBVA	2026-07-24 13:43:15	2026-07-24 13:43:15
16	808	BOLD CF	2026-07-24 13:43:15	2026-07-24 13:43:15
17	32	CAJA SOCIAL	2026-07-24 13:43:16	2026-07-24 13:43:16
18	2	POPULAR	2026-07-24 13:43:17	2026-07-24 13:43:17
19	809	NU	2026-07-24 13:43:19	2026-07-24 13:43:19
\.


--
-- Data for Name: branches; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.branches (id, name, created_at, updated_at) FROM stdin;
10	CIUDAD JARDIN	2026-07-24 15:28:31	2026-07-24 15:28:31
11	UNICENTRO	2026-07-24 15:28:32	2026-07-24 15:28:32
12	JARDIN PLAZA	2026-07-24 15:28:32	2026-07-24 15:28:32
13	PANCE	2026-07-24 15:28:33	2026-07-24 15:28:33
14	BOCHALEMA	2026-07-24 15:28:33	2026-07-24 15:28:33
15	OFICINA	2026-07-24 15:28:33	2026-07-24 15:28:33
16	MERCADEO	2026-07-24 15:28:34	2026-07-24 15:28:34
17	GRANADA	2026-07-24 15:28:34	2026-07-24 15:28:34
\.


--
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.cache (key, value, expiration) FROM stdin;
\.


--
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.cache_locks (key, owner, expiration) FROM stdin;
\.


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
\.


--
-- Data for Name: import_errors; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.import_errors (id, payment_batch_id, severity, code, message, source_sheet, source_row, context, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.invoices (id, payment_batch_id, branch_id, payment_receipt_id, third_party_id, payment_date, detail_document_number, third_party_name, support_document, causation_document, amount, concept, status, source_sheet, source_row, created_at, updated_at) FROM stdin;
3	11	10	3	25	2026-07-02	900311569	AGROPECUARIA CRIADERO VILLA MARIA SAS	001-03FE-00046540-000	001-CCF-00010289	1397445.00	\N	paid	CIUDAD JARDIN	7	2026-07-24 15:28:31	2026-07-24 15:28:31
4	11	10	3	25	2026-07-02	900311569	AGROPECUARIA CRIADERO VILLA MARIA SAS	001-03FE-00046860-000	001-CCF-00010291	1553440.00	\N	paid	CIUDAD JARDIN	8	2026-07-24 15:28:31	2026-07-24 15:28:31
5	11	10	4	58	2026-07-02	901598294	ARMIRENE COLOMBIA SAS	001-FCF-02606021-000	001-FCF-02606021	91350.00	domicilios del 15 al 21 de junio	paid	CIUDAD JARDIN	10	2026-07-24 15:28:31	2026-07-24 15:28:31
6	11	10	4	58	2026-07-02	901598294	ARMIRENE COLOMBIA SAS	001-FCF-02606020-000	001-FCF-02606020	107609.00	domicilios del 8 al 14 de junio	paid	CIUDAD JARDIN	11	2026-07-24 15:28:31	2026-07-24 15:28:31
7	11	10	5	48	2026-07-02	900040299	ATLANTIC FS SAS	001--15504393-000	001-CCF-00010311	152796.00	\N	paid	CIUDAD JARDIN	13	2026-07-24 15:28:31	2026-07-24 15:28:31
8	11	10	6	90	2026-07-02	901784030	BOMBA FOODS SAS	001-VQF-00003173-000	001-CCF-00010310	3210740.00	\N	paid	CIUDAD JARDIN	15	2026-07-24 15:28:31	2026-07-24 15:28:31
9	11	10	6	90	2026-07-02	901784030	BOMBA FOODS SAS	001-VQF-00003134-000	001-CCF-00010262	3236370.00	\N	paid	CIUDAD JARDIN	16	2026-07-24 15:28:31	2026-07-24 15:28:31
10	11	10	7	96	2026-07-02	900232942	BONNIPLAST	001-FEBO-00013888-000	001-CCF-00010298	834903.00	\N	paid	CIUDAD JARDIN	18	2026-07-24 15:28:31	2026-07-24 15:28:31
11	11	10	8	166	2026-07-02	800208785	CONGELADOS AGRICOLAS SA	001-J-20117124-000	001-CCF-00010250	1095626.00	\N	paid	CIUDAD JARDIN	20	2026-07-24 15:28:31	2026-07-24 15:28:31
12	11	10	8	166	2026-07-02	800208785	CONGELADOS AGRICOLAS SA	001-J-20116939-000	001-CCF-00010218	4382077.00	\N	paid	CIUDAD JARDIN	21	2026-07-24 15:28:31	2026-07-24 15:28:31
13	11	10	9	188	2026-07-02	901068725	DANIEL SANCHEZ SAS	001-FELE-00076198-000	001-CCF-00010299	23000.00	\N	paid	CIUDAD JARDIN	23	2026-07-24 15:28:31	2026-07-24 15:28:31
14	11	10	9	188	2026-07-02	901068725	DANIEL SANCHEZ SAS	001-FELE-00076197-000	001-CCF-00010300	45540.00	\N	paid	CIUDAD JARDIN	24	2026-07-24 15:28:31	2026-07-24 15:28:31
15	11	10	9	188	2026-07-02	901068725	DANIEL SANCHEZ SAS	001-FELE-00076199-000	001-CCF-00010301	461587.00	\N	paid	CIUDAD JARDIN	25	2026-07-24 15:28:31	2026-07-24 15:28:31
16	11	10	10	209	2026-07-02	901091355	DISTRIALIMENTOS DEL CAMPO SAS	001-FVE-00034507-000	001-CCF-00010296	1550250.00	\N	paid	CIUDAD JARDIN	27	2026-07-24 15:28:31	2026-07-24 15:28:31
17	11	10	11	206	2026-07-02	890916575	DISTRIBUIDORA DE VINOS Y LICORES SA	001-06FE-00203355-000	001-CCF-00010305	2150357.00	\N	paid	CIUDAD JARDIN	29	2026-07-24 15:28:31	2026-07-24 15:28:31
18	11	10	12	243	2026-07-02	890917780	ELECTROQUIMICA WEST S.A	001--00372655-000	001-CCF-00010293	984365.00	\N	paid	CIUDAD JARDIN	31	2026-07-24 15:28:31	2026-07-24 15:28:31
19	11	10	13	265	2026-07-02	1130634913	FIGUEROA COLLAZOS FARITZA FERNANDA	001-DSF1267-00000000-000	001-DSF-00001267	102663.00	\N	paid	CIUDAD JARDIN	33	2026-07-24 15:28:31	2026-07-24 15:28:31
20	11	10	14	273	2026-07-02	901472752	FRUTOS Y PULPAS SAS	001-FELE-00005060-000	001-CCF-00010306	995000.00	\N	paid	CIUDAD JARDIN	35	2026-07-24 15:28:31	2026-07-24 15:28:31
21	11	10	15	338	2026-07-02	830074144	GLOBAL WINE & SPIRITS LTDA	001-NIF-02605006-000	001-NIF-02605006	-3915514.00	nota credito	paid	CIUDAD JARDIN	37	2026-07-24 15:28:31	2026-07-24 15:28:31
22	11	10	15	338	2026-07-02	830074144	GLOBAL WINE & SPIRITS LTDA	001-NIF-02606002-000	001-NIF-02606002	-2572890.00	nota credito	paid	CIUDAD JARDIN	38	2026-07-24 15:28:31	2026-07-24 15:28:31
23	11	10	15	338	2026-07-02	830074144	GLOBAL WINE & SPIRITS LTDA	001-NIF-02606003-000	001-NIF-02606003	-258000.00	nota credito	paid	CIUDAD JARDIN	39	2026-07-24 15:28:31	2026-07-24 15:28:31
24	11	10	15	338	2026-07-02	830074144	GLOBAL WINE & SPIRITS LTDA	001-SCAL-13383892-000	001-CCF-00010290	12647184.00	Compra de tequila para las 5 sedes/ se cobra a las 4 sedes	paid	CIUDAD JARDIN	40	2026-07-24 15:28:31	2026-07-24 15:28:31
25	11	10	16	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	001-FDCJ-00016127-000	001-CCF-00010264	604100.00	\N	paid	CIUDAD JARDIN	42	2026-07-24 15:28:31	2026-07-24 15:28:31
26	11	10	16	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	001-FDCJ-00016270-000	001-CCF-00010284	1099202.00	\N	paid	CIUDAD JARDIN	43	2026-07-24 15:28:31	2026-07-24 15:28:31
27	11	10	17	329	2026-07-02	901433146	GRUPO GM SAS	001-FELE-00034344-000	001-CCF-00010308	324246.00	\N	paid	CIUDAD JARDIN	45	2026-07-24 15:28:31	2026-07-24 15:28:31
28	11	10	18	373	2026-07-02	890903858	INDUSTRIA NACIONAL DE GASEOSAS SA	001-FVCL-04420640-000	001-CCF-00010194	3226927.00	\N	paid	CIUDAD JARDIN	47	2026-07-24 15:28:31	2026-07-24 15:28:31
29	11	10	19	390	2026-07-02	900422594	INVERSIONES VIVE AGRO S.A.S	001-FEV-00253535-000	001-CCF-00010295	904000.00	\N	paid	CIUDAD JARDIN	49	2026-07-24 15:28:31	2026-07-24 15:28:31
30	11	10	20	537	2026-07-02	800190654	PAPELERIA LOS COLORES SAS	001-FE-00053156-000	001-CCF-00010234	921445.00	\N	paid	CIUDAD JARDIN	51	2026-07-24 15:28:32	2026-07-24 15:28:32
31	11	10	21	549	2026-07-02	900964881	PARROQUIA NUESTRA SEÑORA DE LA RECONCILI	001-FCF-02607001-000	001-FCF-02607001	200000.00	\N	paid	CIUDAD JARDIN	53	2026-07-24 15:28:32	2026-07-24 15:28:32
32	11	10	22	293	2026-07-02	890903939	POSTOBON SA	001-JM-07921996-000	001-CCF-00010303	82000.00	\N	paid	CIUDAD JARDIN	55	2026-07-24 15:28:32	2026-07-24 15:28:32
33	11	10	23	186	2026-07-02	51959168	RONCANCIO VELOSA CLAUDIA PATRICIA	001-FECH-00000695-000	001-CCF-00010294	303810.00	\N	paid	CIUDAD JARDIN	57	2026-07-24 15:28:32	2026-07-24 15:28:32
34	11	10	24	630	2026-07-02	900458352	SALUD ABLE FOODS SAS	001-FE-00016394-000	001-CCF-00010309	66240.00	\N	paid	CIUDAD JARDIN	59	2026-07-24 15:28:32	2026-07-24 15:28:32
35	11	10	25	664	2026-07-02	901176791	SOGNI FOODS SAS	001-SFE-00004392-000	001-CCF-00010292	190553.00	\N	paid	CIUDAD JARDIN	61	2026-07-24 15:28:32	2026-07-24 15:28:32
36	11	10	26	740	2026-07-02	860034118	VILASECA S.A.S.	001-FDE-00037593-000	001-CCF-00010286	748156.00	\N	paid	CIUDAD JARDIN	63	2026-07-24 15:28:32	2026-07-24 15:28:32
37	11	11	27	25	2026-07-02	900311569	AGROPECUARIA CRIADERO VILLA MARIA SAS	002-03FE-00046853-000	002-CCF-00008803	542415.00	\N	paid	UNICENTRO	7	2026-07-24 15:28:32	2026-07-24 15:28:32
38	11	11	27	25	2026-07-02	900311569	AGROPECUARIA CRIADERO VILLA MARIA SAS	002-03FE-00046560-000	002-CCF-00008800	1801250.00	\N	paid	UNICENTRO	8	2026-07-24 15:28:32	2026-07-24 15:28:32
39	11	11	28	48	2026-07-02	900040299	ATLANTIC FS SAS	002--15504392-000	002-CCF-00008810	101864.00	\N	paid	UNICENTRO	10	2026-07-24 15:28:32	2026-07-24 15:28:32
40	11	11	29	90	2026-07-02	901784030	BOMBA FOODS SAS	002-VQF-00003164-000	002-CCF-00008807	2601288.00	\N	paid	UNICENTRO	12	2026-07-24 15:28:32	2026-07-24 15:28:32
41	11	11	30	145	2026-07-02	800027374	CI TECNOLOGIA ALIMENTARIA SA TALSA	002-FCF-02606025-000	002-FCF-02606025	431248.00	\N	paid	UNICENTRO	14	2026-07-24 15:28:32	2026-07-24 15:28:32
42	11	11	31	166	2026-07-02	800208785	CONGELADOS AGRICOLAS SA	002-J-20117123-000	002-CCF-00008761	818198.00	\N	paid	UNICENTRO	16	2026-07-24 15:28:32	2026-07-24 15:28:32
43	11	11	31	166	2026-07-02	800208785	CONGELADOS AGRICOLAS SA	002-J-20116939-000	002-CCF-00008738	1151751.00	\N	paid	UNICENTRO	17	2026-07-24 15:28:32	2026-07-24 15:28:32
44	11	11	32	188	2026-07-02	901068725	DANIEL SANCHEZ SAS	002-FELE-00076192-000	002-CCF-00008815	23000.00	\N	paid	UNICENTRO	19	2026-07-24 15:28:32	2026-07-24 15:28:32
45	11	11	33	209	2026-07-02	901091355	DISTRIALIMENTOS DEL CAMPO SAS	002-FVE-00034484-000	002-CCF-00008811	1582425.00	\N	paid	UNICENTRO	21	2026-07-24 15:28:32	2026-07-24 15:28:32
46	11	11	34	265	2026-07-02	1130634913	FIGUEROA COLLAZOS FARITZA FERNANDA	002-NIF-02606021-000	002-NIF-02606021	594.00	\N	paid	UNICENTRO	23	2026-07-24 15:28:32	2026-07-24 15:28:32
47	11	11	34	265	2026-07-02	1130634913	FIGUEROA COLLAZOS FARITZA FERNANDA	002-DSF926-00000000-000	002-DSF-00000926	14600.00	\N	paid	UNICENTRO	24	2026-07-24 15:28:32	2026-07-24 15:28:32
48	11	11	34	265	2026-07-02	1130634913	FIGUEROA COLLAZOS FARITZA FERNANDA	002-DSF928-00000000-000	002-DSF-00000928	27600.00	\N	paid	UNICENTRO	25	2026-07-24 15:28:32	2026-07-24 15:28:32
49	11	11	34	265	2026-07-02	1130634913	FIGUEROA COLLAZOS FARITZA FERNANDA	002-DSF927-00000000-000	002-DSF-00000927	376022.00	\N	paid	UNICENTRO	26	2026-07-24 15:28:32	2026-07-24 15:28:32
50	11	11	34	265	2026-07-02	1130634913	FIGUEROA COLLAZOS FARITZA FERNANDA	002-DSF929-00000000-000	002-DSF-00000929	450985.00	\N	paid	UNICENTRO	27	2026-07-24 15:28:32	2026-07-24 15:28:32
51	11	11	35	273	2026-07-02	901472752	FRUTOS Y PULPAS SAS	002-FELE-00005054-000	002-CCF-00008812	550000.00	\N	paid	UNICENTRO	29	2026-07-24 15:28:32	2026-07-24 15:28:32
52	11	11	36	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	002-FDCJ-00016395-000	002-CCF-00008838	287899.00	\N	paid	UNICENTRO	31	2026-07-24 15:28:32	2026-07-24 15:28:32
53	11	11	36	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	002-FDAS-00011749-000	002-CCF-00008816	439201.00	\N	paid	UNICENTRO	32	2026-07-24 15:28:32	2026-07-24 15:28:32
54	11	11	37	329	2026-07-02	901433146	GRUPO GM SAS	002-FELE-00034290-000	002-CCF-00008809	321288.00	\N	paid	UNICENTRO	34	2026-07-24 15:28:32	2026-07-24 15:28:32
55	11	11	38	330	2026-07-02	901286481	GRUPO HELPPO SAS	002-FE-00048810-000	002-CCF-00008822	316815.00	base lactea coco	paid	UNICENTRO	36	2026-07-24 15:28:32	2026-07-24 15:28:32
56	11	11	38	330	2026-07-02	901286481	GRUPO HELPPO SAS	002-FE-00048807-000	002-CCF-00008821	1209241.00	guacamole y piña colada	paid	UNICENTRO	37	2026-07-24 15:28:32	2026-07-24 15:28:32
57	11	11	39	373	2026-07-02	890903858	INDUSTRIA NACIONAL DE GASEOSAS SA	002-FVCL-04559048-000	002-CCF-00008772	2772360.00	\N	paid	UNICENTRO	39	2026-07-24 15:28:32	2026-07-24 15:28:32
58	11	11	40	390	2026-07-02	900422594	INVERSIONES VIVE AGRO S.A.S	002-FEV-00252996-000	002-CCF-00008801	359200.00	\N	paid	UNICENTRO	41	2026-07-24 15:28:32	2026-07-24 15:28:32
59	11	11	40	390	2026-07-02	900422594	INVERSIONES VIVE AGRO S.A.S	002-FEV-00254371-000	002-CCF-00008842	371100.00	\N	paid	UNICENTRO	42	2026-07-24 15:28:32	2026-07-24 15:28:32
60	11	11	40	390	2026-07-02	900422594	INVERSIONES VIVE AGRO S.A.S	002-FEV-00253508-000	002-CCF-00008813	392500.00	\N	paid	UNICENTRO	43	2026-07-24 15:28:32	2026-07-24 15:28:32
61	11	11	41	404	2026-07-02	890311625	KOLBITOS S A S	002-6FE-00026584-000	002-CCF-00008826	27000.00	\N	paid	UNICENTRO	45	2026-07-24 15:28:32	2026-07-24 15:28:32
62	11	11	41	404	2026-07-02	890311625	KOLBITOS S A S	002-6FE-00026635-000	002-CCF-00008830	27000.00	\N	paid	UNICENTRO	46	2026-07-24 15:28:32	2026-07-24 15:28:32
63	11	11	41	404	2026-07-02	890311625	KOLBITOS S A S	002-6FE-00026655-000	002-CCF-00008825	45000.00	\N	paid	UNICENTRO	47	2026-07-24 15:28:32	2026-07-24 15:28:32
64	11	11	41	404	2026-07-02	890311625	KOLBITOS S A S	002-6FE-00026562-000	002-CCF-00008765	45000.00	\N	paid	UNICENTRO	48	2026-07-24 15:28:32	2026-07-24 15:28:32
65	11	11	41	404	2026-07-02	890311625	KOLBITOS S A S	002-6FE-00026611-000	002-CCF-00008827	67500.00	\N	paid	UNICENTRO	49	2026-07-24 15:28:32	2026-07-24 15:28:32
66	11	11	42	421	2026-07-02	900985954	LE GRAND FRANCES SAS	002-1A-00032160-000	002-CCF-00008839	32880.00	\N	paid	UNICENTRO	51	2026-07-24 15:28:32	2026-07-24 15:28:32
67	11	11	42	421	2026-07-02	900985954	LE GRAND FRANCES SAS	002-1A-00032121-000	002-CCF-00008820	82200.00	\N	paid	UNICENTRO	52	2026-07-24 15:28:32	2026-07-24 15:28:32
68	11	11	42	421	2026-07-02	900985954	LE GRAND FRANCES SAS	002-1A-00032100-000	002-CCF-00008802	123300.00	\N	paid	UNICENTRO	53	2026-07-24 15:28:32	2026-07-24 15:28:32
69	11	11	43	537	2026-07-02	800190654	PAPELERIA LOS COLORES SAS	002-FE-00053398-000	002-CCF-00008795	70706.00	\N	paid	UNICENTRO	55	2026-07-24 15:28:32	2026-07-24 15:28:32
70	11	11	43	537	2026-07-02	800190654	PAPELERIA LOS COLORES SAS	002-FE-00053367-000	002-CCF-00008789	860016.00	\N	paid	UNICENTRO	56	2026-07-24 15:28:32	2026-07-24 15:28:32
71	11	11	44	293	2026-07-02	890903939	POSTOBON SA	002-JM-07917416-000	002-CCF-00008832	163999.00	\N	paid	UNICENTRO	58	2026-07-24 15:28:32	2026-07-24 15:28:32
72	11	11	45	186	2026-07-02	51959168	RONCANCIO VELOSA CLAUDIA PATRICIA	002-fech-00000698-000	002-CCF-00008835	151905.00	\N	paid	UNICENTRO	60	2026-07-24 15:28:32	2026-07-24 15:28:32
73	11	11	46	664	2026-07-02	901176791	SOGNI FOODS SAS	002-SF-00004387-000	002-CCF-00008819	119095.00	\N	paid	UNICENTRO	62	2026-07-24 15:28:32	2026-07-24 15:28:32
74	11	11	47	735	2026-07-02	1144192780	VICUÑA GOMEZ JESSIE	002-FCF-02606024-000	002-FCF-02606024	1638137.00	\N	paid	UNICENTRO	64	2026-07-24 15:28:32	2026-07-24 15:28:32
75	11	11	48	740	2026-07-02	860034118	VILASECA S.A.S.	002-FDE-00037594-000	002-CCF-00008808	1292655.00	\N	paid	UNICENTRO	66	2026-07-24 15:28:32	2026-07-24 15:28:32
76	11	12	49	25	2026-07-02	900311569	AGROPECUARIA CRIADERO VILLA MARIA SAS	004-03FE-00046361-000	004-CCF-00008761	592775.00	\N	paid	JARDIN PLAZA	7	2026-07-24 15:28:32	2026-07-24 15:28:32
77	11	12	49	25	2026-07-02	900311569	AGROPECUARIA CRIADERO VILLA MARIA SAS	004-03FE-00046858-000	004-CCF-00008850	315060.00	\N	paid	JARDIN PLAZA	8	2026-07-24 15:28:32	2026-07-24 15:28:32
78	11	12	50	48	2026-07-02	900040299	ATLANTIC FS SAS	004--15504393-000	004-CCF-00008859	203728.00	\N	paid	JARDIN PLAZA	10	2026-07-24 15:28:32	2026-07-24 15:28:32
79	11	12	51	90	2026-07-02	901784030	BOMBA FOODS SAS	004-VQF-00003148-000	004-CCF-00008840	474155.00	\N	paid	JARDIN PLAZA	12	2026-07-24 15:28:32	2026-07-24 15:28:32
80	11	12	52	96	2026-07-02	900232942	BONNIPLAST	004-FEBO-00013891-000	004-CCF-00008852	10573.00	\N	paid	JARDIN PLAZA	14	2026-07-24 15:28:32	2026-07-24 15:28:32
81	11	12	52	96	2026-07-02	900232942	BONNIPLAST	004-FEBO-00013876-000	004-CCF-00008854	695740.00	\N	paid	JARDIN PLAZA	15	2026-07-24 15:28:32	2026-07-24 15:28:32
82	11	12	53	166	2026-07-02	800208785	CONGELADOS AGRICOLAS SA	004-J-20116939-000	004-CCF-00008773	1394080.00	\N	paid	JARDIN PLAZA	17	2026-07-24 15:28:32	2026-07-24 15:28:32
83	11	12	53	166	2026-07-02	800208785	CONGELADOS AGRICOLAS SA	004-J-20116891-000	004-CCF-00008762	3959623.00	\N	paid	JARDIN PLAZA	18	2026-07-24 15:28:32	2026-07-24 15:28:32
84	11	12	54	188	2026-07-02	901068725	DANIEL SANCHEZ SAS	004-NIF-02606002-000	004-NIF-02606002	230.00	\N	paid	JARDIN PLAZA	20	2026-07-24 15:28:32	2026-07-24 15:28:32
85	11	12	54	188	2026-07-02	901068725	DANIEL SANCHEZ SAS	004-FELE-00076194-000	004-CCF-00008851	127116.00	\N	paid	JARDIN PLAZA	21	2026-07-24 15:28:32	2026-07-24 15:28:32
86	11	12	55	206	2026-07-02	890916575	DISTRIBUIDORA DE VINOS Y LICORES SA	004-06FE-00203010-000	004-CCF-00008844	1106988.00	\N	paid	JARDIN PLAZA	23	2026-07-24 15:28:32	2026-07-24 15:28:32
87	11	12	56	243	2026-07-02	890917780	ELECTROQUIMICA WEST S.A	004--00372688-000	004-CCF-00008862	57363.00	\N	paid	JARDIN PLAZA	25	2026-07-24 15:28:32	2026-07-24 15:28:32
88	11	12	56	243	2026-07-02	890917780	ELECTROQUIMICA WEST S.A	004--00372498-000	004-CCF-00008856	284045.00	\N	paid	JARDIN PLAZA	26	2026-07-24 15:28:32	2026-07-24 15:28:32
89	11	12	57	265	2026-07-02	1130634913	FIGUEROA COLLAZOS FARITZA FERNANDA	004-DSF785-00000000-000	004-DSF-00000785	5000.00	\N	paid	JARDIN PLAZA	28	2026-07-24 15:28:32	2026-07-24 15:28:32
90	11	12	57	265	2026-07-02	1130634913	FIGUEROA COLLAZOS FARITZA FERNANDA	004-DSF 786-00000000-000	004-DSF-00000786	84546.00	\N	paid	JARDIN PLAZA	29	2026-07-24 15:28:32	2026-07-24 15:28:32
91	11	12	58	273	2026-07-02	901472752	FRUTOS Y PULPAS SAS	004-FELE-00005059-000	004-CCF-00008860	486000.00	\N	paid	JARDIN PLAZA	31	2026-07-24 15:28:32	2026-07-24 15:28:32
92	11	12	59	338	2026-07-02	830074144	GLOBAL WINE & SPIRITS LTDA	004-SCAL-13383882-000	004-CCF-00008847	62454.00	\N	paid	JARDIN PLAZA	33	2026-07-24 15:28:32	2026-07-24 15:28:32
93	11	12	60	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	004-FDCJ-00016283-000	004-CCF-00008861	126000.00	\N	paid	JARDIN PLAZA	35	2026-07-24 15:28:32	2026-07-24 15:28:32
94	11	12	60	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	004-FDCD-00087371-000	004-CCF-00008858	146400.00	\N	paid	JARDIN PLAZA	36	2026-07-24 15:28:32	2026-07-24 15:28:32
95	11	12	60	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	004-FDCJ-00016182-000	004-CCF-00008848	118000.00	\N	paid	JARDIN PLAZA	37	2026-07-24 15:28:32	2026-07-24 15:28:32
96	11	12	61	329	2026-07-02	901433146	GRUPO GM SAS	004-FELE-00034130-000	004-CCF-00008845	241640.00	\N	paid	JARDIN PLAZA	39	2026-07-24 15:28:32	2026-07-24 15:28:32
97	11	12	62	330	2026-07-02	901286481	GRUPO HELPPO SAS	004-FE-00048540-000	004-CCF-00008849	151205.00	piña colada	paid	JARDIN PLAZA	41	2026-07-24 15:28:32	2026-07-24 15:28:32
98	11	12	62	330	2026-07-02	901286481	GRUPO HELPPO SAS	004-FE-00048809-000	004-CCF-00008863	258637.00	mango y base lactea coc	paid	JARDIN PLAZA	42	2026-07-24 15:28:32	2026-07-24 15:28:32
99	11	12	62	330	2026-07-02	901286481	GRUPO HELPPO SAS	004-FE-00048808-000	004-CCF-00008864	302276.00	guacamole	paid	JARDIN PLAZA	43	2026-07-24 15:28:32	2026-07-24 15:28:32
100	11	12	62	330	2026-07-02	901286481	GRUPO HELPPO SAS	004-FE-00048497-000	004-CCF-00008846	302276.00	guacamole	paid	JARDIN PLAZA	44	2026-07-24 15:28:32	2026-07-24 15:28:32
101	11	12	63	373	2026-07-02	890903858	INDUSTRIA NACIONAL DE GASEOSAS SA	004-FVCL-04499440-000	004-CCF-00008800	2284436.00	\N	paid	JARDIN PLAZA	46	2026-07-24 15:28:32	2026-07-24 15:28:32
102	11	12	64	390	2026-07-02	900422594	INVERSIONES VIVE AGRO S.A.S	004-FEV-00252104-000	004-CCF-00008827	518600.00	\N	paid	JARDIN PLAZA	48	2026-07-24 15:28:32	2026-07-24 15:28:32
103	11	12	64	390	2026-07-02	900422594	INVERSIONES VIVE AGRO S.A.S	004-FEV-00252998-000	004-CCF-00008836	518600.00	\N	paid	JARDIN PLAZA	49	2026-07-24 15:28:32	2026-07-24 15:28:32
104	11	12	64	390	2026-07-02	900422594	INVERSIONES VIVE AGRO S.A.S	004-FEV-00253510-000	004-CCF-00008855	563800.00	\N	paid	JARDIN PLAZA	50	2026-07-24 15:28:32	2026-07-24 15:28:32
105	11	12	65	266	2026-07-02	25233450	JARAMILLO HURTADO CLAUDIA	004-FCF-02606019-000	004-FCF-02606019	293494.00	\N	paid	JARDIN PLAZA	52	2026-07-24 15:28:33	2026-07-24 15:28:33
106	11	12	66	404	2026-07-02	890311625	KOLBITOS S A S	004-4FE-00025137-000	004-CCF-00008811	27000.00	\N	paid	JARDIN PLAZA	54	2026-07-24 15:28:33	2026-07-24 15:28:33
107	11	12	66	404	2026-07-02	890311625	KOLBITOS S A S	004-4FE-00025240-000	004-CCF-00008829	36000.00	\N	paid	JARDIN PLAZA	55	2026-07-24 15:28:33	2026-07-24 15:28:33
108	11	12	66	404	2026-07-02	890311625	KOLBITOS S A S	004-4FE-00025277-000	004-CCF-00008830	36000.00	\N	paid	JARDIN PLAZA	56	2026-07-24 15:28:33	2026-07-24 15:28:33
109	11	12	66	404	2026-07-02	890311625	KOLBITOS S A S	004-4FE-00025037-000	004-CCF-00008843	45000.00	\N	paid	JARDIN PLAZA	57	2026-07-24 15:28:33	2026-07-24 15:28:33
110	11	12	66	404	2026-07-02	890311625	KOLBITOS S A S	004-4FE-00025013-000	004-CCF-00008791	67500.00	\N	paid	JARDIN PLAZA	58	2026-07-24 15:28:33	2026-07-24 15:28:33
111	11	12	67	421	2026-07-02	900985954	LE GRAND FRANCES SAS	004-1A-00032101-000	004-CCF-00008831	82200.00	\N	paid	JARDIN PLAZA	60	2026-07-24 15:28:33	2026-07-24 15:28:33
112	11	12	68	537	2026-07-02	800190654	PAPELERIA LOS COLORES SAS	004-FE-00053272-000	004-CCF-00008823	1074122.00	\N	paid	JARDIN PLAZA	62	2026-07-24 15:28:33	2026-07-24 15:28:33
113	11	12	69	626	2026-07-02	901006683	SACOTTO - CAGIGAS S.A.S.	004-G-00845570-000	004-CCF-00008857	153227.00	\N	paid	JARDIN PLAZA	64	2026-07-24 15:28:33	2026-07-24 15:28:33
114	11	12	70	735	2026-07-02	1144192780	VICUÑA GOMEZ JESSIE	004-FCF-02606018-000	004-FCF-02606018	879125.00	\N	paid	JARDIN PLAZA	66	2026-07-24 15:28:33	2026-07-24 15:28:33
115	11	12	71	740	2026-07-02	860034118	VILASECA S.A.S.	004-FDE-00037312-000	004-CCF-00008834	595686.00	\N	paid	JARDIN PLAZA	68	2026-07-24 15:28:33	2026-07-24 15:28:33
116	11	13	72	25	2026-07-02	900311569	AGROPECUARIA CRIADERO VILLA MARIA SAS	008-03FE-00046351-000	008-CCF-00009627	2771636.00	\N	paid	PANCE	7	2026-07-24 15:28:33	2026-07-24 15:28:33
117	11	13	72	25	2026-07-02	900311569	AGROPECUARIA CRIADERO VILLA MARIA SAS	008-03FE-00046877-000	008-CCF-00009633	3030738.00	\N	paid	PANCE	8	2026-07-24 15:28:33	2026-07-24 15:28:33
118	11	13	73	58	2026-07-02	901598294	ARMIRENE COLOMBIA SAS	008-FCF-02606026-000	008-FCF-02606026	267553.00	domicilios de 15 al 21 de junio	paid	PANCE	10	2026-07-24 15:28:33	2026-07-24 15:28:33
119	11	13	73	58	2026-07-02	901598294	ARMIRENE COLOMBIA SAS	008-FCF-02606025-000	008-FCF-02606025	376682.00	domicilios del 8 al 14 de junio	paid	PANCE	11	2026-07-24 15:28:33	2026-07-24 15:28:33
120	11	13	74	90	2026-07-02	901784030	BOMBA FOODS SAS	008-VQF-00003181-000	008-CCF-00009656	114926.00	\N	paid	PANCE	13	2026-07-24 15:28:33	2026-07-24 15:28:33
121	11	13	74	90	2026-07-02	901784030	BOMBA FOODS SAS	008-VQF-00003171-000	008-CCF-00009660	2497061.00	\N	paid	PANCE	14	2026-07-24 15:28:33	2026-07-24 15:28:33
122	11	13	75	96	2026-07-02	900232942	BONNIPLAST	008-FEBO-00013294-000	008-CCF-00009629	491937.00	\N	paid	PANCE	16	2026-07-24 15:28:33	2026-07-24 15:28:33
123	11	13	75	96	2026-07-02	900232942	BONNIPLAST	008-FEBO-00014009-000	008-CCF-00009653	573415.00	\N	paid	PANCE	17	2026-07-24 15:28:33	2026-07-24 15:28:33
124	11	13	76	164	2026-07-02	860000261	COMPANIA NACIONAL DE LEVADURAS LEVAPAN S	008-L-04233523-000	008-CCF-00009647	206162.00	\N	paid	PANCE	19	2026-07-24 15:28:33	2026-07-24 15:28:33
125	11	13	77	166	2026-07-02	800208785	CONGELADOS AGRICOLAS SA	008-J-20117124-000	008-CCF-00009618	660338.00	\N	paid	PANCE	21	2026-07-24 15:28:33	2026-07-24 15:28:33
126	11	13	77	166	2026-07-02	800208785	CONGELADOS AGRICOLAS SA	008-J-20116939-000	008-CCF-00009567	818206.00	\N	paid	PANCE	22	2026-07-24 15:28:33	2026-07-24 15:28:33
127	11	13	78	209	2026-07-02	901091355	DISTRIALIMENTOS DEL CAMPO SAS	008-FVE-00034495-000	008-CCF-00009634	1830075.00	\N	paid	PANCE	24	2026-07-24 15:28:33	2026-07-24 15:28:33
128	11	13	79	206	2026-07-02	890916575	DISTRIBUIDORA DE VINOS Y LICORES SA	008-06FE-00203817-000	008-CCF-00009646	622027.00	\N	paid	PANCE	26	2026-07-24 15:28:33	2026-07-24 15:28:33
129	11	13	79	206	2026-07-02	890916575	DISTRIBUIDORA DE VINOS Y LICORES SA	008-06FE-00203356-000	008-CCF-00009659	1529096.00	\N	paid	PANCE	27	2026-07-24 15:28:33	2026-07-24 15:28:33
130	11	13	80	211	2026-07-02	805010752	DISTRIBUIDORA LA COSTA SA	008-CALI-00054633-000	008-CCF-00009628	236566.00	\N	paid	PANCE	29	2026-07-24 15:28:33	2026-07-24 15:28:33
131	11	13	81	243	2026-07-02	890917780	ELECTROQUIMICA WEST S.A	008--00373040-000	008-CCF-00009652	662647.00	\N	paid	PANCE	31	2026-07-24 15:28:33	2026-07-24 15:28:33
132	11	13	82	257	2026-07-02	800065567	VENTOLINI SA	008-FVIN-00018599-000	008-CCF-00009641	280002.00	\N	paid	PANCE	33	2026-07-24 15:28:33	2026-07-24 15:28:33
133	11	13	83	265	2026-07-02	1130634913	FIGUEROA COLLAZOS FARITZA FERNANDA	008-DSF1016-00000000-000	008-DSF-00001016	7400.00	\N	paid	PANCE	35	2026-07-24 15:28:33	2026-07-24 15:28:33
134	11	13	83	265	2026-07-02	1130634913	FIGUEROA COLLAZOS FARITZA FERNANDA	008-DSF1027-00000000-000	008-DSF-00001027	14800.00	\N	paid	PANCE	36	2026-07-24 15:28:33	2026-07-24 15:28:33
135	11	13	83	265	2026-07-02	1130634913	FIGUEROA COLLAZOS FARITZA FERNANDA	008-DSF1028-00000000-000	008-DSF-00001028	360904.00	\N	paid	PANCE	37	2026-07-24 15:28:33	2026-07-24 15:28:33
136	11	13	83	265	2026-07-02	1130634913	FIGUEROA COLLAZOS FARITZA FERNANDA	008-DSF1015-00000000-000	008-DSF-00001015	537709.00	\N	paid	PANCE	38	2026-07-24 15:28:33	2026-07-24 15:28:33
137	11	13	84	273	2026-07-02	901472752	FRUTOS Y PULPAS SAS	008-FELE-00005081-000	008-CCF-00009655	220000.00	\N	paid	PANCE	40	2026-07-24 15:28:33	2026-07-24 15:28:33
138	11	13	84	273	2026-07-02	901472752	FRUTOS Y PULPAS SAS	008-FELE-00005058-000	008-CCF-00009638	330000.00	\N	paid	PANCE	41	2026-07-24 15:28:33	2026-07-24 15:28:33
139	11	13	85	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	008-FDCJ-00016334-000	008-CCF-00009635	159000.00	\N	paid	PANCE	43	2026-07-24 15:28:33	2026-07-24 15:28:33
140	11	13	85	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	008-FDCJ-00016271-000	008-CCF-00009632	579302.00	\N	paid	PANCE	44	2026-07-24 15:28:33	2026-07-24 15:28:33
141	11	13	86	329	2026-07-02	901433146	GRUPO GM SAS	008-FELE-00034433-000	008-CCF-00009648	199720.00	\N	paid	PANCE	46	2026-07-24 15:28:33	2026-07-24 15:28:33
142	11	13	87	330	2026-07-02	901286481	GRUPO HELPPO SAS	008-FE-00048813-000	008-CCF-00009637	963761.00	\N	paid	PANCE	48	2026-07-24 15:28:33	2026-07-24 15:28:33
143	11	13	88	373	2026-07-02	890903858	INDUSTRIA NACIONAL DE GASEOSAS SA	008-FVCL-47511845-000	008-CCF-00009610	1551300.00	\N	paid	PANCE	50	2026-07-24 15:28:33	2026-07-24 15:28:33
144	11	13	88	373	2026-07-02	890903858	INDUSTRIA NACIONAL DE GASEOSAS SA	008-FVCL-04523591-000	008-CCF-00009619	1565098.00	\N	paid	PANCE	51	2026-07-24 15:28:33	2026-07-24 15:28:33
145	11	13	89	390	2026-07-02	900422594	INVERSIONES VIVE AGRO S.A.S	008-FEV-00253536-000	008-CCF-00009639	813600.00	\N	paid	PANCE	53	2026-07-24 15:28:33	2026-07-24 15:28:33
146	11	13	90	404	2026-07-02	890311625	KOLBITOS S A S	008-6FE-00026475-000	008-CCF-00009630	67500.00	\N	paid	PANCE	55	2026-07-24 15:28:33	2026-07-24 15:28:33
147	11	13	90	404	2026-07-02	890311625	KOLBITOS S A S	008-6FE-00026734-000	008-CCF-00009640	67500.00	\N	paid	PANCE	56	2026-07-24 15:28:33	2026-07-24 15:28:33
148	11	13	91	421	2026-07-02	900985954	LE GRAND FRANCES SAS	008-1A-00032125-000	008-CCF-00009636	82200.00	\N	paid	PANCE	58	2026-07-24 15:28:33	2026-07-24 15:28:33
149	11	13	91	421	2026-07-02	900985954	LE GRAND FRANCES SAS	008-1A-00032165-000	008-CCF-00009645	115080.00	\N	paid	PANCE	59	2026-07-24 15:28:33	2026-07-24 15:28:33
150	11	13	92	537	2026-07-02	800190654	PAPELERIA LOS COLORES SAS	008-FE-00053222-000	008-CCF-00009603	938136.00	\N	paid	PANCE	61	2026-07-24 15:28:33	2026-07-24 15:28:33
151	11	13	93	186	2026-07-02	51959168	RONCANCIO VELOSA CLAUDIA PATRICIA	008-FECH-00000699-000	008-CCF-00009657	303810.00	\N	paid	PANCE	63	2026-07-24 15:28:33	2026-07-24 15:28:33
152	11	13	94	630	2026-07-02	900458352	SALUD ABLE FOODS SAS	008-FE-00016397-000	008-CCF-00009649	58080.00	\N	paid	PANCE	65	2026-07-24 15:28:33	2026-07-24 15:28:33
153	11	13	95	664	2026-07-02	901176791	SOGNI FOODS SAS	008-SF-00004432-000	008-CCF-00009650	142914.00	\N	paid	PANCE	67	2026-07-24 15:28:33	2026-07-24 15:28:33
154	11	13	96	735	2026-07-02	1144192780	VICUÑA GOMEZ JESSIE	008-FCF-02606024-000	008-FCF-02606024	1445663.00	\N	paid	PANCE	69	2026-07-24 15:28:33	2026-07-24 15:28:33
155	11	13	97	740	2026-07-02	860034118	VILASECA S.A.S.	008-FDE-00037597-000	008-CCF-00009584	473314.00	\N	paid	PANCE	71	2026-07-24 15:28:33	2026-07-24 15:28:33
156	11	14	98	25	2026-07-02	900311569	AGROPECUARIA CRIADERO VILLA MARIA SAS	011-03FE-00046857-000	011-CCF-00003792	294806.00	\N	paid	BOCHALEMA	7	2026-07-24 15:28:33	2026-07-24 15:28:33
157	11	14	99	58	2026-07-02	901598294	ARMIRENE COLOMBIA SAS	011-FCF-02606021-000	011-FCF-02606021	612063.00	\N	paid	BOCHALEMA	9	2026-07-24 15:28:33	2026-07-24 15:28:33
158	11	14	99	58	2026-07-02	901598294	ARMIRENE COLOMBIA SAS	011-FCF-02606022-000	011-FCF-02606022	811543.00	\N	paid	BOCHALEMA	10	2026-07-24 15:28:33	2026-07-24 15:28:33
159	11	14	100	48	2026-07-02	900040299	ATLANTIC FS SAS	011--15504392-000	011-CCF-00003801	190995.00	\N	paid	BOCHALEMA	12	2026-07-24 15:28:33	2026-07-24 15:28:33
160	11	14	101	90	2026-07-02	901784030	BOMBA FOODS SAS	011-VQF-00003150-000	011-CCF-00003780	2920655.00	\N	paid	BOCHALEMA	14	2026-07-24 15:28:33	2026-07-24 15:28:33
161	11	14	102	166	2026-07-02	800208785	CONGELADOS AGRICOLAS SA	011-J-20117221-000	011-CCF-00003764	3960777.00	\N	paid	BOCHALEMA	16	2026-07-24 15:28:33	2026-07-24 15:28:33
162	11	14	103	188	2026-07-02	901068725	DANIEL SANCHEZ SAS	011-FELE-00076196-000	011-CCF-00003802	26398.00	\N	paid	BOCHALEMA	18	2026-07-24 15:28:33	2026-07-24 15:28:33
163	11	14	103	188	2026-07-02	901068725	DANIEL SANCHEZ SAS	011-FELE-00076337-000	011-CCF-00003816	241689.00	\N	paid	BOCHALEMA	19	2026-07-24 15:28:33	2026-07-24 15:28:33
164	11	14	103	188	2026-07-02	901068725	DANIEL SANCHEZ SAS	011-FELE-00076195-000	011-CCF-00003803	307449.00	\N	paid	BOCHALEMA	20	2026-07-24 15:28:33	2026-07-24 15:28:33
165	11	14	104	209	2026-07-02	901091355	DISTRIALIMENTOS DEL CAMPO SAS	011-FVE-00034503-000	011-CCF-00003794	1054950.00	\N	paid	BOCHALEMA	22	2026-07-24 15:28:33	2026-07-24 15:28:33
166	11	14	105	206	2026-07-02	890916575	DISTRIBUIDORA DE VINOS Y LICORES SA	011-06FE-00203801-000	011-CCF-00003817	472393.00	\N	paid	BOCHALEMA	24	2026-07-24 15:28:33	2026-07-24 15:28:33
167	11	14	105	206	2026-07-02	890916575	DISTRIBUIDORA DE VINOS Y LICORES SA	011-06FE-00203426-000	011-CCF-00003793	1035950.00	\N	paid	BOCHALEMA	25	2026-07-24 15:28:33	2026-07-24 15:28:33
168	11	14	106	243	2026-07-02	890917780	ELECTROQUIMICA WEST S.A	011--00371851-000	011-CCF-00003805	1360636.00	\N	paid	BOCHALEMA	27	2026-07-24 15:28:33	2026-07-24 15:28:33
169	11	14	107	273	2026-07-02	901472752	FRUTOS Y PULPAS SAS	011-FELE-00005062-000	011-CCF-00003800	468000.00	\N	paid	BOCHALEMA	29	2026-07-24 15:28:33	2026-07-24 15:28:33
170	11	14	108	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	011-FDCJ-00016289-000	011-CCF-00003795	358399.00	\N	paid	BOCHALEMA	31	2026-07-24 15:28:33	2026-07-24 15:28:33
171	11	14	108	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	011-FDCD-00087369-000	011-CCF-00003796	585601.00	\N	paid	BOCHALEMA	32	2026-07-24 15:28:33	2026-07-24 15:28:33
172	11	14	109	329	2026-07-02	901433146	GRUPO GM SAS	011-FCF-02606003-000	011-NIF-02606003	8152.00	\N	paid	BOCHALEMA	34	2026-07-24 15:28:33	2026-07-24 15:28:33
173	11	14	109	329	2026-07-02	901433146	GRUPO GM SAS	011-FELE-00034202-000	011-CCF-00003806	322860.00	\N	paid	BOCHALEMA	35	2026-07-24 15:28:33	2026-07-24 15:28:33
174	11	14	110	330	2026-07-02	901286481	GRUPO HELPPO SAS	011-FE-00048887-000	011-CCF-00003813	258637.00	\N	paid	BOCHALEMA	37	2026-07-24 15:28:33	2026-07-24 15:28:33
175	11	14	110	330	2026-07-02	901286481	GRUPO HELPPO SAS	011-FE-00048884-000	011-CCF-00003814	434350.00	\N	paid	BOCHALEMA	38	2026-07-24 15:28:33	2026-07-24 15:28:33
176	11	14	110	330	2026-07-02	901286481	GRUPO HELPPO SAS	011-FE-00048273-000	011-CCF-00003750	677307.00	\N	paid	BOCHALEMA	39	2026-07-24 15:28:33	2026-07-24 15:28:33
177	11	14	111	373	2026-07-02	890903858	INDUSTRIA NACIONAL DE GASEOSAS SA	011-FVCL-04614539-000	011-CCF-00003784	451094.00	\N	paid	BOCHALEMA	41	2026-07-24 15:28:33	2026-07-24 15:28:33
178	11	14	111	373	2026-07-02	890903858	INDUSTRIA NACIONAL DE GASEOSAS SA	011-FVCL-04642939-000	011-CCF-00003799	1806408.00	\N	paid	BOCHALEMA	42	2026-07-24 15:28:33	2026-07-24 15:28:33
179	11	14	112	390	2026-07-02	900422594	INVERSIONES VIVE AGRO S.A.S	011-FEV-00253509-000	011-CCF-00003797	428200.00	\N	paid	BOCHALEMA	44	2026-07-24 15:28:33	2026-07-24 15:28:33
180	11	14	112	390	2026-07-02	900422594	INVERSIONES VIVE AGRO S.A.S	011-FEV-00254372-000	011-CCF-00003818	473400.00	\N	paid	BOCHALEMA	45	2026-07-24 15:28:33	2026-07-24 15:28:33
181	11	14	113	404	2026-07-02	890311625	KOLBITOS S A S	011-4FE-00025125-000	011-CCF-00003808	40500.00	\N	paid	BOCHALEMA	47	2026-07-24 15:28:33	2026-07-24 15:28:33
182	11	14	113	404	2026-07-02	890311625	KOLBITOS S A S	011-4FE-00025483-000	011-CCF-00003810	45000.00	\N	paid	BOCHALEMA	48	2026-07-24 15:28:33	2026-07-24 15:28:33
183	11	14	113	404	2026-07-02	890311625	KOLBITOS S A S	011-4FE-00024863-000	011-CCF-00003807	54000.00	\N	paid	BOCHALEMA	49	2026-07-24 15:28:33	2026-07-24 15:28:33
184	11	14	114	421	2026-07-02	900985954	LE GRAND FRANCES SAS	011-1A-00032164-000	011-CCF-00003820	98640.00	\N	paid	BOCHALEMA	51	2026-07-24 15:28:33	2026-07-24 15:28:33
185	11	14	115	537	2026-07-02	800190654	PAPELERIA LOS COLORES SAS	011-FE-00053220-000	011-CCF-00003745	898112.00	\N	paid	BOCHALEMA	53	2026-07-24 15:28:33	2026-07-24 15:28:33
186	11	14	115	537	2026-07-02	800190654	PAPELERIA LOS COLORES SAS	011-FE-00053435-000	011-CCF-00003798	1003704.00	\N	paid	BOCHALEMA	54	2026-07-24 15:28:33	2026-07-24 15:28:33
187	11	14	116	570	2026-07-02	900319753	PRICESMART COLOMBIA SAS	011-COFE-03578533-000	011-CCF-00003791	544200.00	\N	paid	BOCHALEMA	56	2026-07-24 15:28:33	2026-07-24 15:28:33
188	11	14	117	626	2026-07-02	901006683	SACOTTO - CAGIGAS S.A.S.	011-G-00846416-000	011-CCF-00003811	64200.00	\N	paid	BOCHALEMA	58	2026-07-24 15:28:33	2026-07-24 15:28:33
189	11	14	118	630	2026-07-02	900458352	SALUD ABLE FOODS SAS	011-FE-00016343-000	011-CCF-00003804	34080.00	\N	paid	BOCHALEMA	60	2026-07-24 15:28:33	2026-07-24 15:28:33
190	11	14	119	601	2026-07-02	16630920	REFRIGERACION VALDES	011-FCF-02606024-000	011-FCF-02606024	216600.00	\N	paid	BOCHALEMA	62	2026-07-24 15:28:33	2026-07-24 15:28:33
191	11	14	120	735	2026-07-02	1144192780	VICUÑA GOMEZ JESSIE	011-FCF-02606023-000	011-FCF-02606023	1950419.00	\N	paid	BOCHALEMA	64	2026-07-24 15:28:33	2026-07-24 15:28:33
192	11	14	121	740	2026-07-02	860034118	VILASECA S.A.S.	011-FDE-00038022-000	011-CCF-00003812	601965.00	\N	paid	BOCHALEMA	66	2026-07-24 15:28:33	2026-07-24 15:28:33
193	11	15	122	126	2026-07-02	31241805	CARRILLO  ROMELIA	005-DSF747-00000000-000	005-DSF-00000747	1317213.00	\N	paid	OFICINA	7	2026-07-24 15:28:33	2026-07-24 15:28:33
194	11	15	123	176	2026-07-02	31474203	CORDOBA CAICEDO MARIA	005-DSF749-00000000-000	005-DSF-00000749	650000.00	\N	paid	OFICINA	9	2026-07-24 15:28:34	2026-07-24 15:28:34
195	11	15	124	10	2026-07-02	79343931	DIAZ CHAVEZ FRANCISCO AURELIO	005-DSF750-00000000-000	005-DSF-00000750	1954522.00	mentocoaching a brian ortiz director franquicia	paid	OFICINA	11	2026-07-24 15:28:34	2026-07-24 15:28:34
196	11	15	124	10	2026-07-02	79343931	DIAZ CHAVEZ FRANCISCO AURELIO	005-DSF751-00000000-000	005-DSF-00000751	4428448.00	consultoria empresarial mentocoaching	paid	OFICINA	12	2026-07-24 15:28:34	2026-07-24 15:28:34
197	11	15	125	308	2026-07-02	94043632	GOMEZ RAMIREZ ANDRES FELIPE	005-FCF-02606086-000	005-FCF-02606086	15000.00	refrigerio comité copasst	paid	OFICINA	14	2026-07-24 15:28:34	2026-07-24 15:28:34
198	11	15	125	308	2026-07-02	94043632	GOMEZ RAMIREZ ANDRES FELIPE	005-FCF-02606087-000	005-FCF-02606087	35000.00	refirgerios comité franquiciados	paid	OFICINA	15	2026-07-24 15:28:34	2026-07-24 15:28:34
199	11	15	126	468	2026-07-02	16799759	MEJIA FALLA VICTOR HUGO	005-DSF744-00000000-000	005-DSF-00000744	1704000.00	\N	paid	OFICINA	17	2026-07-24 15:28:34	2026-07-24 15:28:34
200	11	15	126	468	2026-07-02	16799759	MEJIA FALLA VICTOR HUGO	005-DSF743-00000000-000	005-DSF-00000743	1808957.00	\N	paid	OFICINA	18	2026-07-24 15:28:34	2026-07-24 15:28:34
201	11	16	127	292	2026-07-02	16720297	GARRIDO  ALBERTO	005-DSF746-00000000-000	005-DSF-00000746	577065.00	\N	paid	MERCADEO	7	2026-07-24 15:28:34	2026-07-24 15:28:34
202	11	16	128	758	2026-07-02	1005744761	OTERO ALBARRACIN SALVATORE	005-DSF745-00000000-000	005-DSF-00000745	350001.00	\N	paid	MERCADEO	9	2026-07-24 15:28:34	2026-07-24 15:28:34
203	11	16	129	554	2026-07-02	1105362513	PERDOMO CLAVIJO SANTIAGO	005-DSF742-00000000-000	005-DSF-00000742	900000.00	\N	paid	MERCADEO	11	2026-07-24 15:28:34	2026-07-24 15:28:34
204	11	16	130	747	2026-07-02	66835978	YEPES YEPES CLAUDIA	005-FCF-02606090-000	005-FCF-02606090	24633.00	menu con pestaña jardin plaza	paid	MERCADEO	13	2026-07-24 15:28:34	2026-07-24 15:28:34
205	11	16	130	747	2026-07-02	66835978	YEPES YEPES CLAUDIA	005-FCF-02606088-000	005-FCF-02606088	30791.00	menu con pestaña pance	paid	MERCADEO	14	2026-07-24 15:28:34	2026-07-24 15:28:34
206	11	16	130	747	2026-07-02	66835978	YEPES YEPES CLAUDIA	005-FCF-02606089-000	005-FCF-02606089	30791.00	menu con pestaña bunicentro	paid	MERCADEO	15	2026-07-24 15:28:34	2026-07-24 15:28:34
207	11	17	131	25	2026-07-02	900311569	AGROPECUARIA CRIADERO VILLA MARIA SAS	001-03FE-00046931-000	001-CCF-00008177	864833.00	\N	paid	GRANADA	7	2026-07-24 15:28:34	2026-07-24 15:28:34
208	11	17	131	25	2026-07-02	900311569	AGROPECUARIA CRIADERO VILLA MARIA SAS	001-03FE-00046794-000	001-CCF-00008147	1950113.00	\N	paid	GRANADA	8	2026-07-24 15:28:34	2026-07-24 15:28:34
209	11	17	132	48	2026-07-02	900040299	ATLANTIC FS SAS	001--15504400-000	001-CCF-00008182	127925.00	\N	paid	GRANADA	10	2026-07-24 15:28:34	2026-07-24 15:28:34
210	11	17	133	90	2026-07-02	901784030	BOMBA FOODS SAS	001-VQF-00003198-000	001-CCF-00008185	631430.00	\N	paid	GRANADA	12	2026-07-24 15:28:34	2026-07-24 15:28:34
211	11	17	133	90	2026-07-02	901784030	BOMBA FOODS SAS	001-VQF-00003168-000	001-CCF-00008170	2604940.00	\N	paid	GRANADA	13	2026-07-24 15:28:34	2026-07-24 15:28:34
212	11	17	134	96	2026-07-02	900232942	BONNIPLAST	001-FEBO-00014029-000	001-CCF-00008181	255368.00	\N	paid	GRANADA	15	2026-07-24 15:28:34	2026-07-24 15:28:34
213	11	17	134	96	2026-07-02	900232942	BONNIPLAST	001-FEBO-00013882-000	001-CCF-00008165	313376.00	\N	paid	GRANADA	16	2026-07-24 15:28:34	2026-07-24 15:28:34
214	11	17	135	112	2026-07-02	890303093	CAJA DE COMPENSACION FAMILIAR DEL VALLE	001-T768-02606037-000	001-FCF-02606037	696045.00	\N	paid	GRANADA	18	2026-07-24 15:28:34	2026-07-24 15:28:34
215	11	17	136	166	2026-07-02	800208785	CONGELADOS AGRICOLAS SA	001-J-20117459-000	001-CCF-00008171	1586515.00	\N	paid	GRANADA	20	2026-07-24 15:28:34	2026-07-24 15:28:34
216	11	17	137	188	2026-07-02	901068725	DANIEL SANCHEZ SAS	001-FELE-00076124-000	001-CCF-00008158	125928.00	\N	paid	GRANADA	22	2026-07-24 15:28:34	2026-07-24 15:28:34
217	11	17	137	188	2026-07-02	901068725	DANIEL SANCHEZ SAS	001-FELE-00076193-000	001-CCF-00008159	195673.00	\N	paid	GRANADA	23	2026-07-24 15:28:34	2026-07-24 15:28:34
218	11	17	138	209	2026-07-02	901091355	DISTRIALIMENTOS DEL CAMPO SAS	001-FVE-00034496-000	001-CCF-00008154	785850.00	\N	paid	GRANADA	25	2026-07-24 15:28:34	2026-07-24 15:28:34
219	11	17	138	209	2026-07-02	901091355	DISTRIALIMENTOS DEL CAMPO SAS	001-FVE-00034579-000	001-CCF-00008180	819000.00	\N	paid	GRANADA	26	2026-07-24 15:28:34	2026-07-24 15:28:34
220	11	17	139	206	2026-07-02	890916575	DISTRIBUIDORA DE VINOS Y LICORES SA	001-63FE-00000818-000	001-CCF-00008173	655858.00	\N	paid	GRANADA	28	2026-07-24 15:28:34	2026-07-24 15:28:34
221	11	17	139	206	2026-07-02	890916575	DISTRIBUIDORA DE VINOS Y LICORES SA	001-06FE-00203594-000	001-CCF-00008178	1840754.00	\N	paid	GRANADA	29	2026-07-24 15:28:34	2026-07-24 15:28:34
222	11	17	140	243	2026-07-02	890917780	ELECTROQUIMICA WEST S.A	001--00373039-000	001-CCF-00008186	470424.00	klaxen	paid	GRANADA	31	2026-07-24 15:28:34	2026-07-24 15:28:34
223	11	17	141	257	2026-07-02	800065567	VENTOLINI SA	001-FVIN-00018588-000	001-CCF-00008174	140001.00	\N	paid	GRANADA	33	2026-07-24 15:28:34	2026-07-24 15:28:34
224	11	17	142	273	2026-07-02	901472752	FRUTOS Y PULPAS SAS	001-FELE-00005056-000	001-CCF-00008155	665000.00	\N	paid	GRANADA	35	2026-07-24 15:28:34	2026-07-24 15:28:34
225	11	17	143	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	001-FDLJ-00031758-000	001-CCF-00008169	144000.00	\N	paid	GRANADA	37	2026-07-24 15:28:34	2026-07-24 15:28:34
226	11	17	143	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	001-FDLJ-00031714-000	001-CCF-00008168	468601.00	\N	paid	GRANADA	38	2026-07-24 15:28:34	2026-07-24 15:28:34
227	11	17	143	328	2026-07-02	900338568	GRUPO EMPRESARIAL GIRALDO S S A S	001-FDCD-00087276-000	001-CCF-00008167	732002.00	\N	paid	GRANADA	39	2026-07-24 15:28:34	2026-07-24 15:28:34
228	11	17	144	329	2026-07-02	901433146	GRUPO GM SAS	001-FELE-00034346-000	001-CCF-00008163	201816.00	\N	paid	GRANADA	41	2026-07-24 15:28:34	2026-07-24 15:28:34
229	11	17	145	330	2026-07-02	901286481	GRUPO HELPPO SAS	001-FE-00048893-000	001-CCF-00008156	102800.00	\N	paid	GRANADA	43	2026-07-24 15:28:34	2026-07-24 15:28:34
230	11	17	145	330	2026-07-02	901286481	GRUPO HELPPO SAS	001-FE-00048892-000	001-CCF-00008157	308763.00	\N	paid	GRANADA	44	2026-07-24 15:28:34	2026-07-24 15:28:34
231	11	17	145	330	2026-07-02	901286481	GRUPO HELPPO SAS	001-FE-00048833-000	001-CCF-00008175	944694.00	\N	paid	GRANADA	45	2026-07-24 15:28:34	2026-07-24 15:28:34
232	11	17	146	373	2026-07-02	890903858	INDUSTRIA NACIONAL DE GASEOSAS SA	001-FVCL-04658557-000	001-CCF-00008160	3006389.00	\N	paid	GRANADA	47	2026-07-24 15:28:34	2026-07-24 15:28:34
233	11	17	147	390	2026-07-02	900422594	INVERSIONES VIVE AGRO S.A.S	001-FEV-00254376-000	001-CCF-00008184	499500.00	\N	paid	GRANADA	49	2026-07-24 15:28:34	2026-07-24 15:28:34
234	11	17	147	390	2026-07-02	900422594	INVERSIONES VIVE AGRO S.A.S	001-FEV-00253511-000	001-CCF-00008166	618500.00	\N	paid	GRANADA	50	2026-07-24 15:28:34	2026-07-24 15:28:34
235	11	17	148	266	2026-07-02	25233450	JARAMILLO HURTADO CLAUDIA	001-FCF-02606038-000	001-FCF-02606038	149583.00	\N	paid	GRANADA	52	2026-07-24 15:28:34	2026-07-24 15:28:34
236	11	17	149	421	2026-07-02	900985954	LE GRAND FRANCES SAS	001-1A-00032126-000	001-CCF-00008162	82200.00	\N	paid	GRANADA	54	2026-07-24 15:28:34	2026-07-24 15:28:34
237	11	17	149	421	2026-07-02	900985954	LE GRAND FRANCES SAS	001-1A-00032071-000	001-CCF-00008148	82200.00	\N	paid	GRANADA	55	2026-07-24 15:28:34	2026-07-24 15:28:34
238	11	17	150	469	2026-07-02	94421793	MERA ROSERO OSCAR	001-DSF1611-00000000-000	001-DSF-00001611	10000.00	\N	paid	GRANADA	57	2026-07-24 15:28:34	2026-07-24 15:28:34
239	11	17	150	469	2026-07-02	94421793	MERA ROSERO OSCAR	001-DSF1610-00000000-000	001-DSF-00001610	32967.00	\N	paid	GRANADA	58	2026-07-24 15:28:34	2026-07-24 15:28:34
240	11	17	150	469	2026-07-02	94421793	MERA ROSERO OSCAR	001-DSF1613-00000000-000	001-DSF-00001613	77616.00	\N	paid	GRANADA	59	2026-07-24 15:28:34	2026-07-24 15:28:34
241	11	17	150	469	2026-07-02	94421793	MERA ROSERO OSCAR	001-DSF1612-00000000-000	001-DSF-00001612	132403.00	\N	paid	GRANADA	60	2026-07-24 15:28:34	2026-07-24 15:28:34
242	11	17	151	537	2026-07-02	800190654	PAPELERIA LOS COLORES SAS	001-FE-00053433-000	001-CCF-00008164	305868.00	\N	paid	GRANADA	62	2026-07-24 15:28:34	2026-07-24 15:28:34
243	11	17	152	293	2026-07-02	890903939	GASEOSAS POSADA TOBON SA	001-CA-07356613-000	001-CCF-00008176	616800.00	\N	paid	GRANADA	64	2026-07-24 15:28:34	2026-07-24 15:28:34
244	11	17	153	664	2026-07-02	901176791	SOGNI FOODS SAS	001-SF-00004386-000	001-CCF-00008161	119095.00	\N	paid	GRANADA	66	2026-07-24 15:28:34	2026-07-24 15:28:34
245	11	17	154	681	2026-07-02	860000006	TEAM FOODS COLOMBIA S A	001-EB-00083640-000	001-CCF-00008183	1252370.00	\N	paid	GRANADA	68	2026-07-24 15:28:34	2026-07-24 15:28:34
246	11	17	155	696	2026-07-02	890935900	TOSTADITOS SUSANITA SAS	001-FS-00272468-000	001-CCF-00008172	104400.00	\N	paid	GRANADA	70	2026-07-24 15:28:34	2026-07-24 15:28:34
247	11	17	156	735	2026-07-02	1144192780	VICUÑA GOMEZ JESSIE	001-FCF-02606039-000	001-FCF-02606039	1392286.00	\N	paid	GRANADA	72	2026-07-24 15:28:34	2026-07-24 15:28:34
248	11	17	157	740	2026-07-02	860034118	VILASECA S.A.S.	001-FDE-00038014-000	001-CCF-00008179	323175.00	\N	paid	GRANADA	74	2026-07-24 15:28:34	2026-07-24 15:28:34
\.


--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.job_batches (id, name, total_jobs, pending_jobs, failed_jobs, failed_job_ids, options, cancelled_at, created_at, finished_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.jobs (id, queue, payload, attempts, reserved_at, available_at, created_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	0001_01_01_000000_create_users_table	1
2	0001_01_01_000001_create_cache_table	1
3	0001_01_01_000002_create_jobs_table	1
4	2026_07_10_000001_create_payment_catalog_tables	1
5	2026_07_10_000002_create_payment_batch_tables	1
6	2026_07_10_000003_add_granada_file_path_to_payment_batches_table	1
7	2026_07_23_000001_add_alternate_name_to_third_parties_table	1
8	2026_07_23_000002_add_branch_file_paths_to_payment_batches_table	1
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
\.


--
-- Data for Name: payment_batches; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.payment_batches (id, source_file_name, source_file_path, payment_date, has_model_sheet, status, bank_payment_lines_count, receipts_count, invoices_count, bank_payment_total, invoice_total, bank_file_path, imported_at, created_at, updated_at, granada_file_path, branch_file_paths) FROM stdin;
11	7430a4c8-87e5-45dd-bd55-21f7735059c6.xlsx	/var/www/html/storage/app/private/imports/7430a4c8-87e5-45dd-bd55-21f7735059c6.xlsx	2026-07-02	f	imported	155	155	246	170659986.00	170659986.00	bank-payment-files/payment-batch-11.txt	2026-07-24 15:28:34	2026-07-24 15:28:31	2026-07-24 15:28:34	bank-payment-files/payment-batch-11-granada.txt	{"14":"bank-payment-files\\/payment-batch-11-branch-14-bochalema.txt","10":"bank-payment-files\\/payment-batch-11-branch-10-ciudad-jardin.txt","17":"bank-payment-files\\/payment-batch-11-branch-17-granada.txt","12":"bank-payment-files\\/payment-batch-11-branch-12-jardin-plaza.txt","16":"bank-payment-files\\/payment-batch-11-branch-16-mercadeo.txt","15":"bank-payment-files\\/payment-batch-11-branch-15-oficina.txt","13":"bank-payment-files\\/payment-batch-11-branch-13-pance.txt","11":"bank-payment-files\\/payment-batch-11-branch-11-unicentro.txt"}
\.


--
-- Data for Name: payment_receipts; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.payment_receipts (id, payment_batch_id, branch_id, third_party_id, receipt_number, payment_date, amount, concept, source_sheet, source_row, warnings, created_at, updated_at) FROM stdin;
3	11	10	25	001-PEL-02607001	2026-07-02	2950885.00	\N	CIUDAD JARDIN	9	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
4	11	10	58	001-PEL-02607002	2026-07-02	198959.00	\N	CIUDAD JARDIN	12	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
5	11	10	48	001-PEL-02607003	2026-07-02	152796.00	queso americano	CIUDAD JARDIN	14	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
6	11	10	90	001-PEL-02607004	2026-07-02	6447110.00	cerdo res y pollo desmechado	CIUDAD JARDIN	17	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
7	11	10	96	001-PEL-02607005	2026-07-02	834903.00	\N	CIUDAD JARDIN	19	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
8	11	10	166	001-PEL-02607006	2026-07-02	5477703.00	mccain compra de papas spiral yuquitas y potatoes	CIUDAD JARDIN	22	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
9	11	10	188	001-PEL-02607007	2026-07-02	530127.00	verduras	CIUDAD JARDIN	26	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
10	11	10	209	001-PEL-02607008	2026-07-02	1550250.00	queso mozzarella	CIUDAD JARDIN	28	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
11	11	10	206	001-PEL-02607009	2026-07-02	2150357.00	\N	CIUDAD JARDIN	30	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
12	11	10	243	001-PEL-02607010	2026-07-02	984365.00	klaxen	CIUDAD JARDIN	32	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
13	11	10	265	001-PEL-02607011	2026-07-02	102663.00	lechuga crespa batavia y romana	CIUDAD JARDIN	34	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
14	11	10	273	001-PEL-02607012	2026-07-02	995000.00	pulpa mango y maracuya	CIUDAD JARDIN	36	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
15	11	10	338	001-PEL-02607013	2026-07-02	5900780.00	\N	CIUDAD JARDIN	41	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
16	11	10	328	001-PEL-02607014	2026-07-02	1703302.00	son licores junior/ compra de licor y cerveza	CIUDAD JARDIN	44	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
17	11	10	329	001-PEL-02607015	2026-07-02	324246.00	filete de pollo	CIUDAD JARDIN	46	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
18	11	10	373	001-PEL-02607016	2026-07-02	3226927.00	\N	CIUDAD JARDIN	48	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
19	11	10	390	001-PEL-02607017	2026-07-02	904000.00	apio y zanahoria	CIUDAD JARDIN	50	[]	2026-07-24 15:28:31	2026-07-24 15:28:31
20	11	10	537	001-PEL-02607018	2026-07-02	921445.00	toalla de cocina guantes y tapabocas	CIUDAD JARDIN	52	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
21	11	10	549	001-PEL-02607019	2026-07-02	200000.00	donacion parroquia  mes de julio	CIUDAD JARDIN	54	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
22	11	10	293	001-PEL-02607020	2026-07-02	82000.00	\N	CIUDAD JARDIN	56	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
23	11	10	186	001-PEL-02607021	2026-07-02	303810.00	jalapeños	CIUDAD JARDIN	58	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
24	11	10	630	001-PEL-02607022	2026-07-02	66240.00	pulpa mora y lulo	CIUDAD JARDIN	60	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
25	11	10	664	001-PEL-02607023	2026-07-02	190553.00	brownies	CIUDAD JARDIN	62	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
26	11	10	740	001-PEL-02607024	2026-07-02	748156.00	tocineta-jamon	CIUDAD JARDIN	64	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
27	11	11	25	002-PEL-02607001	2026-07-02	2343665.00	\N	UNICENTRO	9	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
28	11	11	48	002-PEL-02607002	2026-07-02	101864.00	queso americano	UNICENTRO	11	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
29	11	11	90	002-PEL-02607003	2026-07-02	2601288.00	cerdo res y pollo desmechado	UNICENTRO	13	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
30	11	11	145	002-PEL-02607004	2026-07-02	431248.00	gorros negros y de cuello dotacion	UNICENTRO	15	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
31	11	11	166	002-PEL-02607005	2026-07-02	1969949.00	mccain papas spiral yuquitas y potatoes	UNICENTRO	18	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
32	11	11	188	002-PEL-02607006	2026-07-02	23000.00	verduras	UNICENTRO	20	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
33	11	11	209	002-PEL-02607007	2026-07-02	1582425.00	queso mozzarella	UNICENTRO	22	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
34	11	11	265	002-PEL-02607008	2026-07-02	869801.00	lechuga crespa romana y batavia verduras	UNICENTRO	28	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
35	11	11	273	002-PEL-02607009	2026-07-02	550000.00	pulpa mango y maracuya	UNICENTRO	30	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
36	11	11	328	002-PEL-02607010	2026-07-02	727100.00	son licores junior/ compra de licor y cerveza	UNICENTRO	33	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
37	11	11	329	002-PEL-02607011	2026-07-02	321288.00	filete de pollo	UNICENTRO	35	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
38	11	11	330	002-PEL-02607012	2026-07-02	1526056.00	\N	UNICENTRO	38	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
39	11	11	373	002-PEL-02607013	2026-07-02	2772360.00	\N	UNICENTRO	40	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
40	11	11	390	002-PEL-02607014	2026-07-02	1122800.00	apio y zanahoria	UNICENTRO	44	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
41	11	11	404	002-PEL-02607015	2026-07-02	211500.00	\N	UNICENTRO	50	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
42	11	11	421	002-PEL-02607016	2026-07-02	238380.00	pan de hamburguesa	UNICENTRO	54	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
43	11	11	537	002-PEL-02607017	2026-07-02	930722.00	toalla de cocina, ejementos de papeleria y desechables	UNICENTRO	57	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
44	11	11	293	002-PEL-02607018	2026-07-02	163999.00	\N	UNICENTRO	59	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
45	11	11	186	002-PEL-02607019	2026-07-02	151905.00	jalapeños	UNICENTRO	61	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
46	11	11	664	002-PEL-02607020	2026-07-02	119095.00	brownies	UNICENTRO	63	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
47	11	11	735	002-PEL-02607021	2026-07-02	1638137.00	servicio de domicilios  del 14 al 28 de junio	UNICENTRO	65	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
48	11	11	740	002-PEL-02607022	2026-07-02	1292655.00	tocineta -jamon-salami-peperoni	UNICENTRO	67	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
49	11	12	25	004-PEL-02607001	2026-07-02	907835.00	\N	JARDIN PLAZA	9	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
50	11	12	48	004-PEL-02607002	2026-07-02	203728.00	queso americano	JARDIN PLAZA	11	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
51	11	12	90	004-PEL-02607003	2026-07-02	474155.00	cerdo res y pollo desmechado	JARDIN PLAZA	13	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
52	11	12	96	004-PEL-02607004	2026-07-02	706313.00	\N	JARDIN PLAZA	16	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
53	11	12	166	004-PEL-02607005	2026-07-02	5353703.00	mccain papas spiral yuquitas y potatoes	JARDIN PLAZA	19	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
54	11	12	188	004-PEL-02607006	2026-07-02	127346.00	verduras	JARDIN PLAZA	22	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
55	11	12	206	004-PEL-02607007	2026-07-02	1106988.00	\N	JARDIN PLAZA	24	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
56	11	12	243	004-PEL-02607008	2026-07-02	341408.00	klaxen	JARDIN PLAZA	27	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
57	11	12	265	004-PEL-02607009	2026-07-02	89546.00	verdura-lechuga batavia crespa romana	JARDIN PLAZA	30	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
58	11	12	273	004-PEL-02607010	2026-07-02	486000.00	pulpa mango y maracuya	JARDIN PLAZA	32	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
59	11	12	338	004-PEL-02607011	2026-07-02	62454.00	licor	JARDIN PLAZA	34	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
60	11	12	328	004-PEL-02607012	2026-07-02	390400.00	son licores junior/ compra de licor y cerveza	JARDIN PLAZA	38	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
61	11	12	329	004-PEL-02607013	2026-07-02	241640.00	filete de pollo	JARDIN PLAZA	40	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
62	11	12	330	004-PEL-02607014	2026-07-02	1014394.00	\N	JARDIN PLAZA	45	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
63	11	12	373	004-PEL-02607015	2026-07-02	2284436.00	\N	JARDIN PLAZA	47	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
64	11	12	390	004-PEL-02607016	2026-07-02	1601000.00	apio y zanahoria	JARDIN PLAZA	51	[]	2026-07-24 15:28:32	2026-07-24 15:28:32
65	11	12	266	004-PEL-02607017	2026-07-02	293494.00	materiales para reparaciones locativas	JARDIN PLAZA	53	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
66	11	12	404	004-PEL-02607018	2026-07-02	211500.00	\N	JARDIN PLAZA	59	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
67	11	12	421	004-PEL-02607019	2026-07-02	82200.00	pan de hamburguesa	JARDIN PLAZA	61	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
68	11	12	537	004-PEL-02607020	2026-07-02	1074122.00	toalla de cocina, guantes y papeleria	JARDIN PLAZA	63	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
69	11	12	626	004-PEL-02607021	2026-07-02	153227.00	\N	JARDIN PLAZA	65	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
70	11	12	735	004-PEL-02607022	2026-07-02	879125.00	domicilios  del 15 al 28 de junio	JARDIN PLAZA	67	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
71	11	12	740	004-PEL-02607023	2026-07-02	595686.00	tocineta	JARDIN PLAZA	69	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
72	11	13	25	008-PEL-02607001	2026-07-02	5802374.00	\N	PANCE	9	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
73	11	13	58	008-PEL-02607002	2026-07-02	644235.00	\N	PANCE	12	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
74	11	13	90	008-PEL-02607003	2026-07-02	2611987.00	cerdo res y pollo desmechado	PANCE	15	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
75	11	13	96	008-PEL-02607004	2026-07-02	1065352.00	\N	PANCE	18	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
76	11	13	164	008-PEL-02607005	2026-07-02	206162.00	salsa de tomate	PANCE	20	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
77	11	13	166	008-PEL-02607006	2026-07-02	1478544.00	mccain papas spiral yuquitas y potatoes	PANCE	23	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
78	11	13	209	008-PEL-02607007	2026-07-02	1830075.00	queso mozzarella	PANCE	25	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
79	11	13	206	008-PEL-02607008	2026-07-02	2151123.00	\N	PANCE	28	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
80	11	13	211	008-PEL-02607009	2026-07-02	236566.00	azucar	PANCE	30	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
81	11	13	243	008-PEL-02607010	2026-07-02	662647.00	klaxen	PANCE	32	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
82	11	13	257	008-PEL-02607011	2026-07-02	280002.00	helado	PANCE	34	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
83	11	13	265	008-PEL-02607012	2026-07-02	920813.00	lechuga crespa batavia y romana	PANCE	39	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
84	11	13	273	008-PEL-02607013	2026-07-02	550000.00	apio y zanahoria	PANCE	42	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
85	11	13	328	008-PEL-02607014	2026-07-02	738302.00	son licores junior/ compra de licor y cerveza	PANCE	45	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
86	11	13	329	008-PEL-02607015	2026-07-02	199720.00	filete de pollo	PANCE	47	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
87	11	13	330	008-PEL-02607016	2026-07-02	963761.00	guacamole y piña colada	PANCE	49	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
88	11	13	373	008-PEL-02607017	2026-07-02	3116398.00	\N	PANCE	52	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
89	11	13	390	008-PEL-02607018	2026-07-02	813600.00	apio y zanahoria	PANCE	54	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
90	11	13	404	008-PEL-02607019	2026-07-02	135000.00	\N	PANCE	57	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
91	11	13	421	008-PEL-02607020	2026-07-02	197280.00	pan de hamburguesa	PANCE	60	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
92	11	13	537	008-PEL-02607021	2026-07-02	938136.00	toallas para cocina-desechables-guantes manipulacion alimentos	PANCE	62	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
93	11	13	186	008-PEL-02607022	2026-07-02	303810.00	jalapeños	PANCE	64	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
94	11	13	630	008-PEL-02607023	2026-07-02	58080.00	pulpa mora y lulo	PANCE	66	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
95	11	13	664	008-PEL-02607024	2026-07-02	142914.00	brownie	PANCE	68	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
96	11	13	735	008-PEL-02607025	2026-07-02	1445663.00	servicio de domicilios del 15 al 28 de junio	PANCE	70	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
97	11	13	740	008-PEL-02607026	2026-07-02	473314.00	tocineta -salami-jamon	PANCE	72	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
98	11	14	25	011-PEL-02607001	2026-07-02	294806.00	\N	BOCHALEMA	8	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
99	11	14	58	011-PEL-02607002	2026-07-02	1423606.00	\N	BOCHALEMA	11	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
100	11	14	48	011-PEL-02607003	2026-07-02	190995.00	\N	BOCHALEMA	13	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
101	11	14	90	011-PEL-02607004	2026-07-02	2920655.00	\N	BOCHALEMA	15	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
102	11	14	166	011-PEL-02607005	2026-07-02	3960777.00	\N	BOCHALEMA	17	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
103	11	14	188	011-PEL-02607006	2026-07-02	575536.00	\N	BOCHALEMA	21	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
104	11	14	209	011-PEL-02607007	2026-07-02	1054950.00	\N	BOCHALEMA	23	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
105	11	14	206	011-PEL-02607008	2026-07-02	1508343.00	\N	BOCHALEMA	26	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
106	11	14	243	011-PEL-02607009	2026-07-02	1360636.00	\N	BOCHALEMA	28	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
107	11	14	273	011-PEL-02607010	2026-07-02	468000.00	\N	BOCHALEMA	30	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
108	11	14	328	011-PEL-02607011	2026-07-02	944000.00	\N	BOCHALEMA	33	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
109	11	14	329	011-PEL-02607012	2026-07-02	331012.00	\N	BOCHALEMA	36	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
110	11	14	330	011-PEL-02607013	2026-07-02	1370294.00	\N	BOCHALEMA	40	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
111	11	14	373	011-PEL-02607014	2026-07-02	2257502.00	\N	BOCHALEMA	43	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
112	11	14	390	011-PEL-02607015	2026-07-02	901600.00	\N	BOCHALEMA	46	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
113	11	14	404	011-PEL-02607016	2026-07-02	139500.00	\N	BOCHALEMA	50	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
114	11	14	421	011-PEL-02607017	2026-07-02	98640.00	\N	BOCHALEMA	52	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
115	11	14	537	011-PEL-02607018	2026-07-02	1901816.00	\N	BOCHALEMA	55	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
116	11	14	570	011-PEL-02607019	2026-07-02	544200.00	\N	BOCHALEMA	57	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
117	11	14	626	011-PEL-02607020	2026-07-02	64200.00	\N	BOCHALEMA	59	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
118	11	14	630	011-PEL-02607021	2026-07-02	34080.00	\N	BOCHALEMA	61	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
119	11	14	601	011-PEL-02607022	2026-07-02	216600.00	\N	BOCHALEMA	63	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
120	11	14	735	011-PEL-02607023	2026-07-02	1950419.00	\N	BOCHALEMA	65	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
121	11	14	740	011-PEL-02607024	2026-07-02	601965.00	\N	BOCHALEMA	67	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
122	11	15	126	005-PEL-02607001	2026-07-02	1317213.00	canon arrendamiento julio bodega san fernando	OFICINA	8	[]	2026-07-24 15:28:33	2026-07-24 15:28:33
123	11	15	176	005-PEL-02607002	2026-07-02	650000.00	canon arrendamiento taller mmto	OFICINA	10	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
124	11	15	10	005-PEL-02607003	2026-07-02	6382970.00	\N	OFICINA	13	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
125	11	15	308	005-PEL-02607004	2026-07-02	50000.00	cobro por mttos	OFICINA	16	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
126	11	15	468	005-PEL-02607005	2026-07-02	3512957.00	servicio y consumo de mistery shopper cobro mmto	OFICINA	19	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
127	11	16	292	005-PEL-02607006	2026-07-02	577065.00	habladores	MERCADEO	8	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
128	11	16	758	005-PEL-02607007	2026-07-02	350001.00	dj pance 27 junio	MERCADEO	10	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
129	11	16	554	005-PEL-02607008	2026-07-02	900000.00	sesion de fotos profesional	MERCADEO	12	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
130	11	16	747	005-PEL-02607009	2026-07-02	86215.00	\N	MERCADEO	16	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
131	11	17	25	001-PEL-02607001	2026-07-02	2814946.00	\N	GRANADA	9	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
132	11	17	48	001-PEL-02607002	2026-07-02	127925.00	queso americano	GRANADA	11	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
133	11	17	90	001-PEL-02607003	2026-07-02	3236370.00	cerdo res y pollo desmechado	GRANADA	14	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
134	11	17	96	001-PEL-02607004	2026-07-02	568744.00	\N	GRANADA	17	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
135	11	17	112	001-PEL-02607005	2026-07-02	696045.00	plan complementario salud hector hector	GRANADA	19	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
136	11	17	166	001-PEL-02607006	2026-07-02	1586515.00	mccaciin papas en spiral yuquitas y potatoes	GRANADA	21	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
137	11	17	188	001-PEL-02607007	2026-07-02	321601.00	verduras	GRANADA	24	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
138	11	17	209	001-PEL-02607008	2026-07-02	1604850.00	queso mozzarella	GRANADA	27	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
139	11	17	206	001-PEL-02607009	2026-07-02	2496612.00	\N	GRANADA	30	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
140	11	17	243	001-PEL-02607010	2026-07-02	470424.00	\N	GRANADA	32	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
141	11	17	257	001-PEL-02607011	2026-07-02	140001.00	helado	GRANADA	34	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
142	11	17	273	001-PEL-02607012	2026-07-02	665000.00	pulpa mango y maracuya	GRANADA	36	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
143	11	17	328	001-PEL-02607013	2026-07-02	1344603.00	son licores junior/ compra de licor y cerveza	GRANADA	40	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
144	11	17	329	001-PEL-02607014	2026-07-02	201816.00	filete de pollo	GRANADA	42	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
145	11	17	330	001-PEL-02607015	2026-07-02	1356257.00	\N	GRANADA	46	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
146	11	17	373	001-PEL-02607016	2026-07-02	3006389.00	\N	GRANADA	48	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
147	11	17	390	001-PEL-02607017	2026-07-02	1118000.00	apio y znaahoria	GRANADA	51	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
148	11	17	266	001-PEL-02607018	2026-07-02	149583.00	maeteriales para reparaciones locativs	GRANADA	53	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
149	11	17	421	001-PEL-02607019	2026-07-02	164400.00	pan de hamburguesa	GRANADA	56	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
150	11	17	469	001-PEL-02607020	2026-07-02	252986.00	el trebol lechuga batavia romana y crespa	GRANADA	61	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
151	11	17	537	001-PEL-02607021	2026-07-02	305868.00	\N	GRANADA	63	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
152	11	17	293	001-PEL-02607022	2026-07-02	616800.00	\N	GRANADA	65	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
153	11	17	664	001-PEL-02607023	2026-07-02	119095.00	brownies	GRANADA	67	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
154	11	17	681	001-PEL-02607024	2026-07-02	1252370.00	aceite	GRANADA	69	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
155	11	17	696	001-PEL-02607025	2026-07-02	104400.00	crotouns	GRANADA	71	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
156	11	17	735	001-PEL-02607026	2026-07-02	1392286.00	domicilios del 15 al 28 de junio	GRANADA	73	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
157	11	17	740	001-PEL-02607027	2026-07-02	323175.00	tocineta	GRANADA	75	[]	2026-07-24 15:28:34	2026-07-24 15:28:34
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.sessions (id, user_id, ip_address, user_agent, payload, last_activity) FROM stdin;
cutZzrk384DoAb8rlo2l5o0I70EN3rssmAoDqBr4	6	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	eyJfdG9rZW4iOiJiZ1lhWTMzV2I0WVExMmRudDREek9CQmVqOXI2UVA4clRwenlXY1BQIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwXC9hZG1pblwvaW1wb3J0c1wvMTFcL2JhbmstZmlsZVwvYnJhbmNoZXNcLzEwIiwicm91dGUiOiJhZG1pbi5pbXBvcnRzLmJyYW5jaC1iYW5rLWZpbGUifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119LCJ1cmwiOltdLCJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI6Nn0=	1784907414
\.


--
-- Data for Name: third_parties; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.third_parties (id, document_number, person_type, name, created_at, updated_at, alternate_name) FROM stdin;
76	8150008636	1	AVIDESA (MAC POLLO)	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
77	9009872426	1	BAFFONI Y BAFFONI SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
10	79343931	2	DIAZ CHAVEZ FRANCISCO AURELIO	2026-07-24 13:43:05	2026-07-24 13:43:05	\N
12	900285366	1	ABTL SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
13	901498749	1	A&B SOLUCIONES INTEGRALES	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
14	900644894	1	ABS SOLUCIONES INFORMATICA SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
15	34564022	2	ADRIANA ALZATE	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
16	9003126690	1	AC COLOMBIAN L A WYERS-CIRCULO EMPRESARIAL-EDITORES	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
17	860536345	1	ACCESORIOS Y ACABADOS S A S	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
18	901537403	1	ACEROS ALUMINIO VIDRIOS EL BISEL SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
19	76190016	2	ACOSTA OROZCO JOSE DIMAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
20	901154147	1	AP COMPUTADORES SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
21	900836444	1	AGC ELECTRONICA SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
22	8605005060	1	AGENCIA DE VIAJES AZ SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
23	900810915	1	AGROAVANZA SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
24	900595992	1	AGROCITRICOS DEL VALLE SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
26	67005086	2	AGUDELO LEIDY JHOANA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
27	16375199	2	AGUDELO SANCHES FREDY GIOVANNI	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
28	9004078901	1	AKERMOS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
29	31965344	2	AIDA LUCIA CERTUCHE	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
30	8909192674	1	ALARMAR LTDA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
31	1143866820	2	ALDERRETE BASTIDAS ANDRES FELIPE	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
32	9001960661	1	ALFA Y OMEGA INSTRUMENTACION SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
33	396704	2	ALEJANDRO ANGEL BRAVO	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
35	9013846280	1	ALIANZA Y GESTION ESTRATEGICA SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
37	9011683725	1	ALMI FINACIERA SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
38	900212550	1	ALMACENES LA 13	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
39	860500480	1	ALMACENES CORON SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
42	8040163058	1	ALHUM LIMITADA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
43	1144154824	1	ALZATE AMAYA VANESSA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
44	66828189	2	ATEHORTUA MARTHA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
45	8001869606	1	ALTIPAL	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
46	16651398	2	ALVARO LENNIS ARANA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
36	9009141101	1	ALIANZA INTEGRAL CON SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
47	9007877260	1	AML PROTECCION Y DOTACION INDUSTRIAL SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
48	9000402990	1	ATLANTIC FS SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
49	9002108001	1	ANDES SERVICIO DE CERTIFICACION DIGITAL SA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
41	830501310	1	ANDINO TECNOLOGIA LTDA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
50	8050135918	1	ANGEL DIAGNOSTICA SA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
51	1144050323	2	ANDRES FELIPE RESTREPO	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
52	900357051	1	AQALAB LABORATORIO SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
53	38120099	2	ARCILA DE BARRETO MARIA GLADIS/ LAVADO DE TOLDOS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
54	1144152483	2	ARIAS ROJAS LINA MARCELA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
55	31871600	2	ARCE MALDONADO JACQUELINE	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
57	16718401	2	ARCILA MONTES OCTAVIO	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
58	9015982943	1	ARMIRENE COLOMBIA SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
59	8002443874	1	ARCOS DORADOS COLOMBIA SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
60	16846173	2	ARCOS MARTINEZ ARLES	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
61	8903002081	1	ARROCERA LA ESMERALDA SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
62	9001835286	1	ARIOS COLOMBIA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
63	1130591354	2	ARISTIZABAL MONTOYA CAROLINA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
64	901799809	1	AULA VIRTUAL TRAINING SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
65	8050056731	1	AURM GARCIA Y CIA.S.EN.C	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
66	901606650	1	AUTOMATIZACION Y TECNOLOGIA INNOVADORA PARA EL FUT	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
67	19298463	2	APARICIO LOPEZ CARLOS ALIRIO	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
68	900742250	1	ARTIAIRE	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
69	8001186601	1	ARKOS SISTEMAS ARQUITECTONICOS SA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
70	900748143	1	ASESORES DE RECLUTAMIENTO COLOMBIA S,A S	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
72	800193579	1	ASOCIACION COLOMBIANA DE LA INDUSTRIA GASTRONOMICA ACODRES	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
73	8001935791	1	ASOCIACION COLOMBIANA DE LA INDUSTRIA GASTRONOMICA ACODRES	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
74	901652053	1	ASTRO CORP SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
75	900170380	1	ATENCION  MEDICA OCUPACIONAL	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
78	7161908	2	BAFFONI EMANUELE ENRICO	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
80	8600343137	1	BANCO DAVIVIENDA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
81	8903002794	1	BANCO DE OCCIDENTE	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
82	8902007567	1	BANCO PICHINCHA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
85	31273138	2	BARONA MUÑOZ MIRIAM PATRICIA	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
86	94379964	2	BARBOSA OCAMPO HECTOR JAIME	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
87	1059907291	2	BASTIDAS BURBANO ILDER ARLEY	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
88	9014141899	1	BATERIAS SERVICENTRO SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
89	1130585513	2	BERMUDEZ GUASAQUILLO JHON FREDY	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
90	901784030	1	BOMBA FOODS SAS	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
91	890399000	1	BENEMERITO CUERPO DE BOMBEROS VOLUNTARIOS DE CALI	2026-07-24 13:43:14	2026-07-24 13:43:14	\N
92	31245608	2	BELLINI AYALA LUCIA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
93	900383746	1	BIENSA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
94	9001478027	1	BIOSA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
95	41462299	2	BONILLA GONZALEZ YOLANDA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
96	9002329423	1	BONNIPLAST	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
56	16749847	2	CARLOS ARCILA	2026-07-24 13:43:14	2026-07-24 13:43:15	\N
71	890982524	2	CENTRO INTERAMERICANO JURIDICO FINANCIERO	2026-07-24 13:43:14	2026-07-24 13:43:15	\N
40	8903300352	1	ENRIKO	2026-07-24 13:43:14	2026-07-24 13:43:16	\N
84	31918745	2	QUINTERO CARRILLO SANDRA	2026-07-24 13:43:14	2026-07-24 13:43:20	\N
79	9004983268	1	MES SOLUCIONES HCQC GRANADA CTA AHORROS	2026-07-24 13:43:14	2026-07-24 13:43:18	\N
11	901758305	1	SUMINISTROS INDUSTRIALES INDUSAFE SAS	2026-07-24 13:43:14	2026-07-24 13:43:21	\N
25	9003115698	1	AGROPECUARIA CRIADERO VILLA MARIA SAS	2026-07-24 13:43:14	2026-07-24 13:45:52	\N
97	10496183	2	BOLAÑOS ALVARES CARLOS ALBERTO	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
98	1144034161	2	BOLIVAR ROJAS JUAN PABLO	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
99	16940387	2	BOTERO BEDOYA DUVAN ANDRES	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
100	70690299	2	BOTERO GOMEZ GILDARDO DE JESUS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
101	9009859700	1	BLOODHOUND CONSULTING	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
102	900170357	1	BOM CONSULTING GROUP SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
103	901167294	1	BUFFATO COMERCIAL SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
105	14839290	2	BURITICA SALGADO GUSTAVO ADOLFO	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
106	860535488	1	BTU SERVICONTROLES LTDA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
107	31987501	2	CABEZAS MARTHA CECILIA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
108	9005779171	1	CAFÉ MULATO ORGANICO SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
109	1130654715	2	CAICEDO FAUSTO GERARDO	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
110	1234189973	2	CAICEDO CORDOBA DUVAN ANDRES	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
111	66770564	2	CAICEDO OSPINA MARIA SOLANGE	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
113	1125782316	2	CALAMBAS PACHECO JHON FREEDY	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
114	1113515577	2	CALDERON MORA NAYARI	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
115	8050048756	1	CALZATODO SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
116	19392140	1	CALLE ANGEL ALVARO DE JESUS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
34	8605313153	1	CAJA DE COMPENSACION COMFENALCO	2026-07-24 13:43:14	2026-07-24 13:43:15	\N
117	8903030935	1	CAJA DE COMPENSACION FAMILIAR	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
118	900375592	1	CAJAS FUERTES LIZ SAFE SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
119	38872611	2	CAMACHO ADRIANA/UNITED CARGO GROUP	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
120	6382268	2	CAMAYO QUINTERO JOSE VICENTE	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
121	8903990011	1	CAMARA DE COMERCIO DE CALI	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
122	31579845	2	CAMPO MORENO CLAUDIA MARCELA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
123	10534033	2	CAMPOS MUÑOZ ILDEBRANDO	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
124	1144041636	2	CAMPO PULIDO JUAN DAVID	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
125	66959356	2	CARDENAS RIOS MARIA YANETH	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
126	31241805	2	CARRILLO ROMELIA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
127	16825649	2	CARVAJAL ARANGUREN	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
129	8050184951	1	CERDOS DEL VALLE	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
131	34512382	2	CASTILLO ALVARO	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
132	16285939	2	CASTRO BOLIVAR WINSTON	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
133	79317527	2	CARVAJAL ISAZA LOUIS DIDIER	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
134	1143926098	2	CASTAÑO LOPEZ JOHN HAIVER	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
135	16917091	2	CEBALLOS RAMIREZ JAIRO ANDRES	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
136	1144090983	2	CEDEÑO SERRANO MARIA JULIA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
137	8002567696	1	CENTRAL CONTROL SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
138	901127967	1	CENTRO MEDICO EN SEGURIDAD Y SALUD EN EL TRABAJO	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
139	900350234	1	CENTRO TINTAS INSUMOS Y RECARGAS SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
140	16706347	2	CIFUENTES SARRIA JHON JAIRO	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
141	890321156	1	CIUDADELA COMERCIAL UNICENTRO	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
142	8903211567	1	CIUDADELA COMERCIAL UNICENTRO	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
143	900654100	1	CIMAZ SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
144	9005007710	1	CI LA COSECHA DEL VALLE	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
146	901874458	1	CLIMA ZERO SOCIEDAD POR ACCONES SIMPLIFICADAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
147	901290221	1	CLUB DEPORTIVO PUMAS CALI HOCKEY CLUB SP	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
148	890301160	1	CLUB PROFESIONAL DEPORTIVO CALI SA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
149	9001554913	1	COEXISTIR AGROINDUSTRIAL COOPETARIVA DE TRABAJO	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
150	8600345941	1	COLPATRIA SA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
152	1125642373	2	COLORADO QUINTERO EDGAR	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
153	1144100548	2	COLORADO QUINTERO MARIO ANDRES	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
154	9014268920	1	COLECTIVO DE ECONOMIA CIRCULAR COLOMBIA SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
155	94532559	2	COLLAZOS GUSTAVO	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
156	1143843283	2	COLLAZOS SAAVEDRA JULIAN ALBERTO	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
157	8305137293	1	COMBUSTIBLES DE COLOMBIA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
158	8050047392	1	COMERCIAL DE INOXIDABLES ARISTI LTDA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
159	9001095772	1	COMERCIALIADORA CQ LTDA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
160	805021782	1	COMERCIALIZADORA FLORARIA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
161	900664015	1	COMERCIALIZADORA DE BIENES Y SERVICIOS SOLUCIONAMOS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
162	900186315	1	COMERCIALIZADORA TEJADITOS SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
163	900685493	1	COMERQUIAGUAS SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
165	31952879	2	CONDE HERRON MARTHA CECILIA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
166	800208785	1	CONGELADOS AGRICOLAS SA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
167	900335020	1	CONFORRTOTAL SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
168	9018970561	1	CONSULTORES CAMBIARIOS ASOCIADOS SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
169	9000036172	1	CONSORCIO EMCALI	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
170	9011490411	1	CONTROL TOTAL Y PH SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
171	901850650	1	CONSTRUCCIONES A OROZCO SAS	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
172	9005596921	1	CONSORCIO SUPREMA	2026-07-24 13:43:15	2026-07-24 13:43:15	\N
173	8170004995	1	CONVERTIDORA DE PAPEL DE PAPEL DEL CAUCA SA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
174	860007327	1	COOPERATIVA DE AHORRO Y CREDITO FINCOMERCIO	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
175	805015591	1	CORPORACION DE RECREACION Y CULTURA B.D	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
177	31858258	2	CORTES MARIA TERESA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
178	900407889	1	COTIZAR UNIFORMES Y DOTACIONES SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
180	9001354158	1	CREAR PUBLICIDAD EXTERIORES SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
128	79145970	2	INGENIERIA METALMETALICAS	2026-07-24 13:43:15	2026-07-24 13:43:17	\N
104	31834927	2	MARIA CLARA BUILES ESTRADA	2026-07-24 13:43:15	2026-07-24 13:43:18	\N
179	900421730	1	CRAFT DECORACIONES SAS	2026-07-24 13:43:16	2026-07-24 13:43:19	\N
130	67033597	2	QUINTEO RAMIREZ CRISTINA	2026-07-24 13:43:15	2026-07-24 13:43:20	\N
176	31474203	2	CORDOBA CAICEDO MARGOT MARIA	2026-07-24 13:43:16	2026-07-24 14:13:23	CORDOBA CAICEDO MARIA
145	8000273749	1	CI TECNOLOGIA ALIMENTARIA SA TALSA	2026-07-24 13:43:15	2026-07-24 14:06:04	TECNOLOGIA ALIMENTARIA
112	890303093	1	CAJA DE COMPENSACION FAMILIAR DEL VALLE	2026-07-24 13:43:15	2026-07-24 14:24:14	CAJA DE COMPENSACION COMFENALCO
181	94534948	2	CRUZ RAMIREZ LEONARDO	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
182	80034716	2	CHAVISTA SANTIS DAVID LEO	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
183	87573897	2	CHAVEZ CERON YONY WVEYMAR	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
184	16704552	2	CHAVEZ BENAVIDEZ LUIS OVIDIO	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
185	16638661	2	CHICA SANCHEZ MIGUEL HERNANDO	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
187	900812942	1	DA ACABADOS SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
188	901068725	1	DANIEL SANCHEZ SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
189	805010305	1	DISEÑO Y DESARROLLO DE SOFTWARE E.U	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
190	900297803	1	DATA DIGITAL	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
191	16698790	2	DAVILA AGUIRRE JOSE FERNANDO	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
192	1107069368	2	DAZA ACOSTA JHONNY ANDRES	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
193	901624283	1	DECOREKO SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
194	31889659	2	DELGADO GUERRA ALICIA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
195	1144079507	2	DELGADO BASTIDAS FABIAN ALEXANDER	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
196	31320281	2	DELGADO MONETRO ROSA LEYDI	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
197	18186963	2	DE LA PAVA ANDRES DAVID	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
198	805002135	1	DE LA PAVA Y COMPAÑÍA SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
199	9010666081	1	DEL HUERTO Y MAS SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
200	9019698811	1	DGP COMMERCE GROUP SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
201	9006872070	1	DLP SOLUCIONES ELECTRICAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
202	900013167	1	DIAZ Y RESTREPO SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
203	901787572	1	DIGITAL SEND SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
204	901038972	1	DIGITAL INC IMPORTS SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
205	901238105	1	DISDECOL SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
207	9008814956	1	DISROMARA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
208	31952380	1	DISTRI COPYPARTES	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
209	9010913557	1	DISTRIALIMENTOS DEL CAMPO SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
210	900013119	1	DISTRIALFA DEL PACIFICO SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
211	8050107523	1	DISTRIBUIDORA LA COSTA SA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
212	8050014520	1	DISTRIBUIDORA INDUSTRIAL GODOY	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
213	9006513288	1	DISTRIFRUVER SAN ANTONIO SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
214	9006229031	1	DISTRISERVICIOS Y PRODUCTOS SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
215	6558819	2	DISTRIMATERIALES ROJAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
216	8909304485	1	DIVERTRONICA MEDELLIN SA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
217	900899936	1	DMV DISTRIBUIDOR DE MATERIALES DEL VALLE	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
218	901600750	1	DODO AGENCIA DE MARKETING SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
219	1144074939	2	DOMINGUEZ LIBREROS CARLOS ANDRES	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
220	1144107282	2	DOMINGEZ MONTALVO LAURA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
221	8301457438	1	DOMICITY SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
222	1005871855	2	DUCUARA SALAS JOSE DANIEL	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
223	31885003	2	DUEÑAS TOBON CLAUDIA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
224	94506160	2	DUARTE BRAVO FRANCESCO	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
225	1193414948	2	DUQUE FRANCO VALENTINA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
226	1115069130	1	DUQUE MAURICIO	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
227	9011174653	1	DROCCIDENTE SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
228	9015607814	1	DRONE TOURS COLOMBIA SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
229	900773788	1	E-COMMERCE MULTITIENDAS SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
230	8300398543	1	ECOLAB	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
231	1010021387	2	ECHEVERRY IBARBO ALLEN DAVID	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
232	94385182	2	ECHEVERRY LUIS MIGUEL	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
233	14636655	2	ECHEVERRY PULGARIN ROBEIRO ANDRES	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
234	8903126885	1	EDIFICADORA CONTINENTAL SA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
235	900687414	1	EDWIN FIGUEROA VARELA ABOGADOS SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
151	16451870	2	EDGAR COLORADO	2026-07-24 13:43:15	2026-07-24 13:43:16	\N
236	9012105698	1	EFFECTIA SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
237	8903236352	2	EL COMERCIO ELECTRICO SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
238	8903017521	1	EL PAIS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
239	901496824	1	EL RANCHO DE JONAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
240	901143158	1	ELECTRONICA SAN NICOLAS SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
242	8000981359	1	ELECTRO SEGURIDAD ANDINA ELSA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
244	8903042334	1	ELECTROVENTAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
245	800126785	1	EMERMEDICA SA SERVICIOS DE AMBULANCA PREPAGADA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
246	800205597	2	ENFERMERAS SERVICIOS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
247	12747588	2	ERASO MOSCOSO MARIO FERNANDO	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
248	8903256011	1	ESPECIALIDADES DIAGNOSTICAS IHR LTDA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
250	800118202	1	ESTELAR IMPRESORES LTDA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
251	900350102	1	EUROMOBILIA SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
252	900062992	1	EVACOL	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
253	900670505	1	EVENSITE SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
254	9019183075	1	EXPERIENCIAS DIVERSION PLUS SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
255	901453221	1	EXTRACTORES ATMOSFERICOS IM SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
256	901100150	1	FARALLONES MUNDO ELECTRICO SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
258	8000785220	1	FABRICA DE CALZADO ROMULO SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
259	8020050500	1	FABRICA DE CONFITES DROMEDARIO SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
260	31846788	2	FAJARDO ORTIZ MERCEDES	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
261	890303215	1	FEDERACION NACIONAL DE COMERCIANTES EMPRESARIOS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
262	860013488	1	FEDERACION NACIONAL DE COMERCIANTES FENALCO	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
263	1232589444	2	FERNANDEZ TORRES FELIPE JOSE	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
264	901621611	1	FIDEICOMISO MASTER TRUST MONEYTECH	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
265	1130634913	2	FIGUEROA COLLAZOS FARITZA FERNANDA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
267	9017306934	1	FLORENCIO RITUAL DE SABORES SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
249	29099971	2	LEYDA LETICIA ESQUIVEL DE ZULUAGA	2026-07-24 13:43:16	2026-07-24 13:43:22	\N
206	8909165754	1	DISTRIBUIDORA DE VINOS Y LICORES SA	2026-07-24 13:43:16	2026-07-24 13:48:43	DISLICORES SAS
186	51959168	2	RONCANCIO VELOSA CLAUDIA PATRICIA	2026-07-24 13:43:16	2026-07-24 14:03:55	CHILES GOURMET GROUP
257	8000655675	1	FABRICA DE ALIMENTOS PROCESADOS VENTOLINI SA	2026-07-24 13:43:17	2026-07-24 14:09:57	VENTOLINI SA
269	9000172812	1	FRANCO MURGUEITO & ASESORES	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
270	805018722	1	FRIOMASTER SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
271	901008217	1	FRIPAL SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
272	900311276	1	FRITEMOS SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
273	9014727523	1	FRUTOS Y PULPAS SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
274	830129648	1	FONDO DE EMPLEADOS DE SODEXO COLOMBIA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
275	8050052207	1	FONDO DE EMPLEADOS DE SEGURIDAD DE OCCIDENTE	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
276	811045362	1	FORMEX SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
277	900106873	1	FOGEL ANDINA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
278	9001484946	1	FUNDACION PARA LOS ANCIANOS ABANDONADOS LA MISERICORDIA DE JESUS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
279	9001298321	1	FUNDACION DELIRIO	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
280	900310413	1	FUNDACION TIERRA NUEVA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
281	9015694620	1	FUNDACION PARA LA PROMOCION Y EL APOYO AL CICLISMO DEL VALLE DEL CAUCA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
282	890103697	1	FRIGORIFICO LA PARISIENE	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
283	31988007	2	GALLEGO ARRECHEA MARIA EUGENIA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
284	66977044	2	GALLEGO MURIEL PAOLA CAROLINA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
285	900116028	1	GAMASOFT	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
286	16697486	2	GARCES GUERRERO CARLOS ENRIQUE	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
287	77007901	2	GARCES PADILLA HECTORMARIO	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
288	19086925	2	GARCIA ARANGO GUSTAVO	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
289	94064892	2	GARCIA CARDENAS JUAN FERNANDO	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
290	1144165631	2	GARCIA CAMPO LINA MARCELA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
291	1193139575	2	GARCIA MEJIA MARIA CAROLINA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
294	1144159508	2	GAVIRIA ORTIZ HAIDER DAVID	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
295	9002172645	1	GESTION Y PROYECTOS GP SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
296	1144102977	2	GIL GOMEZ SEBASTIAN	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
297	16692350	2	GIL LUNA ANTINIO JOSE	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
298	900690476	1	GIL BUILES SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
299	9000074508	1	GILSA SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
300	1144203056	2	GIRALDO BONILLA VALENTINA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
301	16941510	2	GIRALDO CANTUCA MAURICIO	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
302	1143842617	2	GIRALDO SANCHEZ ANTONIO	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
303	75101083	2	GIRALDO SERNA OSCAR MAURICIO	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
304	1090273006	2	GIRALDO VANEGAS CRISTIAN DAVID	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
306	900040284	1	GODOY & CALDAS COMERCIALIZADORA LIMITADA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
307	52086703	2	GODOY MEJIA SANDRA MILENA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
308	94043632	2	GOMEZ RAMIREZ ANDRES FELIPE	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
309	1130660217	1	GOMEZ CAICEDO CARLOS ARBEY	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
310	94543651	2	GOMEZ GARCIA JUNIOR DAVID	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
311	29125734	2	GOMEZ M. MYRIAM ADREA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
312	94412267	2	GONGORA SANCHEZ NICOLAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
313	76337233	2	GONZALEZ AGRONO JOSE ISRAEL	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
314	14897838	2	GONZALEZ CASTELLANOS DIEGO FERNANDO	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
315	66958842	2	GONZALEZ EMILSE	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
316	1112489930	2	GONZALEZ JARAMILLO EDWIN ALEJANDO	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
317	66948427	2	GONZALEZ MARTHA ISABEL	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
318	16784263	2	GONZALEZ GIL DIEGO FERNANDO	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
319	34329866	2	GUZMAN ALZATE MELISSA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
320	805017818	1	GRIVANINGENIERIA	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
321	16618071	2	GRANADA LOPEZ FERNANDO	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
322	94431299	2	GRIJALBA VICTOR	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
323	1144032286	2	GRISALES QUICENO JAMES ALBERTO	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
324	901536366	1	GRUPO ACERO Y CONFORT JM SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
325	901955790	1	GRUPO COMERCIAL JVC SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
326	9004475843	1	GRUPO COEXISTIR	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
327	8001653771	1	GRUPO DECOR SAS	2026-07-24 13:43:16	2026-07-24 13:43:16	\N
329	9014331463	1	GRUPO GM SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
330	901286481	1	GRUPO HELPPO SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
331	901784851	1	GRUPO MARGLOB SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
332	1105362147	2	GUERRA GONZALEZ LUCY	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
333	16675143	2	GUTIERREZ GARCIA CESAR	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
334	94398231	2	GUITIERREZ WILLIAM	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
335	94520989	2	GUTIERREZ CALDERON ANDRES FERNANDO	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
336	16799272	2	GUSTAVO ADOLFO LUNA SALAZAR	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
337	900802562	1	GYG GOLDEN INVESTMEN SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
338	830074144	1	GWS GLOBALWINE Y SPIRITS LTDA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
339	9011536029	1	HBC GROUP SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
340	805017257	1	H G HOLDING GROUP SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
341	1144051218	2	HERMES PEREZ JESSICA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
342	805024798	1	HENAO HERNANDEZ ABOGADA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
343	29808404	2	HENAO HERNANDEZ MARIA VICTORIA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
344	1110595837	2	HENAO TORRES SEBASTIAN	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
345	76267292	2	HERNANDEZ HURTADO HERMILSON (JARDINERO)	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
346	38565536	2	HERNADEZ LUNA ANGELICA MARIA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
347	1144182966	2	HERNANDEZ FLORES DIANA MARCELA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
348	1107515647	2	HERNANDEZ OSPINA MARYURY	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
349	1143878366	2	HERNANDEZ VALDERRAMA LEYDI TATIAN	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
350	1110363256	2	HERNANDEZ VELEZ SEBASTIAN	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
351	900104945	1	HIPERCENTRO DRYWALL SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
352	31894318	2	HILARION MUÑOZ CONSUELO PATRICIA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
353	901267577	1	HIDROCONSTRUCCIONES GW SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
354	901178096	1	HYDRO CARE LABORATORIO SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
305	8300741440	1	GLOBAL WINE & SPIRITS LTDA	2026-07-24 13:43:17	2026-07-24 13:51:23	GLOBAL WINE Y SPIRITS LTDA
328	9003385688	1	GRUPO EMPRESARIAL GIRALDO S S A S	2026-07-24 13:43:16	2026-07-24 13:53:01	\N
292	16720297	2	GARRIDO RENGIFO ALBERTO	2026-07-24 13:43:17	2026-07-24 14:16:33	GARRIDO  ALBERTO
355	16729227	2	HOLGUIN CAICEDO LUIS CARLOS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
356	830052998	1	HOTSDIME COM CO SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
357	800065539	1	HOTELES ROYAL SA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
358	1006183879	2	HURTADO PEÑALOSA DANIELA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
359	6551378	2	HOYOS ARISTIZABAL ALEX DUBEIMAR	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
360	31981438	2	IBAGON MUÑOZ MARIA DEL PILAR	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
361	9007846807	1	IBO GROUP	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
362	901277516	1	IMAGINE VISUAL LAB SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
363	9013605920	1	IMPERVALLE SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
364	66883659	2	INLICORES SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
365	805019778	1	INFOTECH DE COLOMBIA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
366	8300586777	1	IFX NETWORKS COLOMBIA SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
367	900318577	1	ILUMINACION Y METALELECTRICOS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
368	8605189940	1	INDES	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
369	9005287246	1	INDUSTRIA ALIMENTICIA ALAMO	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
370	860051447	1	INDUSTRIAS CRUZ HERMANOS SA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
371	8903230529	1	INDUSTRIA  COLOMBIANA DE PAPELES INCOLPA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
372	901299158	1	INDUSTRIAS METAL MUÑOZ SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
374	891500202	1	INDUSTRIAS NORTECAUCANAS SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
375	8050059171	1	INDUSTRIAS DOLLY Y COMPAÑÍA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
376	860511886	1	INDUSTRIAS LA CORUÑA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
377	9007994662	1	INGENIERIA METALMETALICA SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
378	1006034166	2	IRURITA GUTIERRREZ JORGE ANDRES	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
379	900748838	1	INSE INGENIERIA Y SEGURIDAD SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
380	860012336	1	INSTITUTO COLOMBIANO DE NORMAS TECNICAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
381	31869204	2	INTEGRADOS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
382	805017589	1	INTERSALUD OCUPACIONAL SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
383	900372199	1	INVERSIONES BOTERO Y BOTERO SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
384	900423755	1	INVERSIONES LA BOQUERIA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
385	8903282194	1	INVERSIONES LOS HIGUERONES	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
386	8020245652	1	INVERSIONES FLOR DE LIZ SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
387	9000917889	1	INTERPLASTICOS COLOMIA SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
388	9007569581	1	INVEERSIONES VALQUIN SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
389	900401209	1	INVERSIONES VELASA SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
391	9004602638	1	INNOVATE SOLUCIONES	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
392	800222648	1	INVERPRIMOS SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
393	169359069	2	JAVIER ALONSO QUIJANO MONTOYA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
266	25233450	2	JARAMILLO HURTADO CLAUDIA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
394	1144207309	2	JARAMILLO OSPINA DANIELA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
395	1130639861	2	JEFFRY AEDO CIFUENTES	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
396	901685709	1	JOLC INGENIERIA SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
397	94431912	2	JOSE F MUÑOZ	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
398	14899347	2	JORGE HERNAN GONZALEZ	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
399	1144187928	2	JOAN FABRICIO  RENGIFO VALDERRAMA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
400	1234197099	2	JUAN ESTEBAN PUERTAS RAMIREZ	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
401	1144085599	2	JUAN MANUEL ARDILA QUIROGA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
402	77022937	2	JUVENAL CEBALLOS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
403	9003685101	1	KLAXEN	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
405	1144047742	2	KOALY TATIANA BENAVIDEZ BOLAÑOS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
406	901401925	1	KONTRASTUDIOS SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
407	900818921	1	KOPPS COMMERCIAL SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
408	805029880	1	LA BOCHA	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
409	9015416893	1	LCDS INGENIERIA SAS	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
410	8903308071	1	LABORATORIO DE ALIMENTOS Y SIMILARES MICROQUIM	2026-07-24 13:43:17	2026-07-24 13:43:17	\N
411	16916374	2	LABRADA VARELA JAIME	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
412	9006409179	1	LACTEOS LA CALIDAD	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
413	900162081	1	LA CARAMELA SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
414	4059508	2	LAGOS MOJICA EBERARDO	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
415	31991300	2	LANDAZURI CABEZAS GLADYS Ayde	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
416	9004150512	1	LA FACTORIA GIORMET	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
417	9002137590	1	LA RECETTA SOLUCIONES	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
418	900496125	1	LARES GESTION INMOBILIARIA SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
419	901561509	2	LAS DELICIAS DE ARA SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
420	901794483	1	LAVANDERIA WJH SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
421	900985954	1	LE GRAND FRANCES SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
422	900931706	1	LEAL COLOMBIA SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
423	67024341	2	LEON SARMIENTO LAURA MARCELA	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
424	9015275722	1	LEBOR	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
426	10248406	2	LIMPIASEO	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
427	800097226	1	LIGA VALLECAUCANA	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
429	9008164888	1	LIVING ESPACIOS SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
425	9007314810	1	LA FLORA/LES GROUP	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
430	31971179	1	LEON MOYA BEATRIZ	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
431	1113668514	1	LUCUMI LOPEZ MARIA CAMILA	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
432	41962251	2	LUGO MARTINEZ ALEXANDRA	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
433	16276415	2	LUNA ORTEGON JUAN FERNANDO	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
434	14894908	2	LONDOÑO COBO CARLOS ALBERTO	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
435	800090625	1	LOS TEJADITOS SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
436	1107104677	2	LOPEZ MAHECHA FRANCISCO	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
437	94072961	2	LOZADA DAZA GUSTAVO ADOLFO	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
438	38600191	2	LOSADA MANRIQUE VANESSA	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
439	1130610713	2	MANCILLA FIGUEEROA YON JENRY	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
440	901379456	1	MANUFACTURERA ADITIVA IP 3D SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
441	16838408	2	HIDALO FIGUEROA HECTRO FABIO	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
442	900434009	1	MACROTICS SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
373	8909038587	1	INDUSTRIA NACIONAL DE GASEOSAS SA	2026-07-24 13:43:17	2026-07-24 13:55:27	\N
404	8903116257	1	KOLBITOS S A S	2026-07-24 13:43:17	2026-07-24 14:07:29	KOLBITOS SAS
443	9004340093	1	MACROTICS SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
444	94454276	2	MACHADO AGREDO YILBER	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
445	901836074	1	MAELEC MATERIALES ELECTROINDUSTRIALES	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
446	9000592385	1	MAKRO	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
447	66902822	2	MARIA DE LOS ANGELES	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
448	1017244845	2	MARCILLO LOPEZ MARIA ALEJANDRA	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
449	900007881	1	MARKETING TOOLS SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
450	1144159179	2	MAS BROWNIE GOURMET BROWNIESERIA	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
451	8605310972	1	MASTER QUIMICA SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
452	14571054	2	MARIN SERNA MILTON CESAR	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
453	1192760606	2	MARTINEZ CASTAÑEDA ALEXANDRA	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
455	29177300	2	MARTINEZ MONTAÑO ADENARY	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
456	901311565	1	MAKROTECHOS S A S	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
457	6550821	2	MAYA BARRIOS EDUARDO	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
458	1130642158	2	AFC VIVIENDA	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
459	901119356	1	MECATRONICA DE COLOMBIA SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
460	9016102399	1	MEGA COMPUTER SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
461	14622408	2	MENDEZ JARAMILLO JOHNNY ALEJANDRO	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
462	10551773	2	MENDEZ YESID	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
463	901506206	1	MENUPP SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
464	31877074	2	MEJIA ARISTIZABAL ADRIANA MARCELA	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
465	901120988	1	MEJIA ARQUITECTO SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
466	16794510	2	MEJIA GARCIA CARLOS ARTURO	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
467	43741462	2	MEJIA GOMEZ MARIA ALEJANDRA	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
468	16799759	2	MEJIA FALLA VICTOR HUGO	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
241	1143864662	2	MEJIA PINO JUAN CAMILO	2026-07-24 13:43:16	2026-07-24 13:43:18	\N
469	94421793	2	MERA ROSERO OSCAR	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
470	890319806	1	MERCADEO	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
471	9000612249	1	MERCAMIO SA	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
472	900061224	1	MERCAMIO SA	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
473	1144094815	2	MERA RINCON VICTOR	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
474	9018088232	2	ME GROUP SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
475	9018088454	2	ME INVESTMENTS SAS	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
476	1144102577	2	MESA OSPINA ANDRES DAVID	2026-07-24 13:43:18	2026-07-24 13:43:18	\N
477	94427302	2	MESIAS SILVA WALTER GUIVANNI	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
478	9010176722	1	METRICOS JG SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
479	9008475081	1	METRO TECHNOLOGY SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
480	16537727	2	MICOLTA GARRIDO PABLO JOSE	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
481	16692055	2	MIRANDA ESCOBAR JOSE DAVID	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
482	9004274778	1	MICRONANONICS TECHNOLOGIES SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
483	8050190409	1	MICROLAB SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
484	1107510015	2	MOLINA LOZANO SEBASTIAN	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
485	31262998	2	MOLINA DE RINCON ELSY	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
486	1144048142	2	MONCADA MEJIA MARIBEL	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
487	66729644	2	MONICA ANDREA CIFUENTES SALAZAR	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
488	1112458652	2	MONTES JARAMILLO JORGE ANDRES	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
454	1143880029	2	MONTAÑO ESCOBAR DANIEL ESTEBAN	2026-07-24 13:43:18	2026-07-24 13:43:19	\N
489	1144064091	2	MONTOYYA DIAZ UAN PABLO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
490	31583177	2	MONTENEGRO LUZ	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
491	1143851257	2	MORA SOTO ANGIE CAROLINA	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
492	1144195751	2	MORALES NOREÑA BRAYAN ALEJANDOR	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
493	1088308783	2	MORALES RIVERA JHONATHAN	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
494	1144093997	2	MORENO VASQUEZ MATEO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
495	16659094	2	MORENO ZAPATAEDUARDO ANTONIO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
496	16732427	2	MORENO NOVOA JAVIER JOSE	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
497	900663051	1	MUNDO LED ILUMINACION SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
498	900708359	1	MUNDO DEL DEPORTEMEDTGOL SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
499	901257828	1	MULTIREDES Y TECNOLOGIA SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
500	6106801	2	MURILLO MOSQUERA GUSTAVO ADOLFO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
501	9015581976	1	MUSKY TROSKY SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
502	900632226	1	MU TEAM SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
503	38886901	2	MUÑOZ CARMONA MONICA	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
505	66919960	2	MUÑOZ PEREZ MRIA DEL PILAR	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
506	16781579	2	MUÑOZ RICHARD	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
507	901147371	1	NATUFOOD	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
508	1118303838	1	NAVIA ANDRES	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
509	94501832	2	NAVARRO ARIAS CESAR ANDRES	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
510	1151954448	2	NOGUERA DEL MAR JULIO CESAR	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
511	94449386	2	OCAMPO LOPEZ CARLOS ALQUIVER	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
512	1130662616	2	OCAMPO SOTO DIEGO FERNANDO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
513	94388058	2	OLARTE MATEUS DIEGO FERNANDO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
514	1112476683	2	OJEDA GALLEGO LIZETH ANDREA	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
515	1144204314	2	ORDOÑEZ QUEVEDO GISSEL TATIANA	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
516	16700350	2	ORJUELA ROJAS FRANCISCO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
517	8000218119	1	OSA ORGANIZACIÓN SAYCO Y ACINPRO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
268	31231757	2	OSPINA DE ROSALES FRANCIA	2026-07-24 13:43:17	2026-07-24 13:43:19	\N
518	9773002	2	OSPINA DUQUE LUIS GABRIEL	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
519	1107048680	2	OSORIO BOLIVAR ANABEL	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
520	1144181104	2	OSORIO HINCAPIE PAULA ANDREA	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
521	1018433279	2	OSPINA NAVARRETE LUIS ALBERTO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
522	9001871163	1	OPTICOLOR SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
523	1130618218	2	OROZCO AMBUILLA ANDRES	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
524	1107528134	2	OROZCO RODRIGUEZ LUIS FELIPE	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
525	1144087334	2	ORTEGON SANCHEZ ANDRES FELIPE	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
526	94505413	2	ORTIZ CALVO JUAN CARLOS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
527	1144191294	2	ORTIZ LOZANO ANDRES FELIPE	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
528	1112968840	2	ORREGO HOYOS CESAR EUGENIO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
529	79544703	2	OVALLE HERNANDEZ MAURICIO ALBERTO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
530	9008756127	1	OPE PACIFICO SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
531	901086447	1	PA. FILIANZA	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
532	800125352	2	PACIFIC	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
533	1110362514	2	PACHECO SAMUEL LEONEL	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
534	900474556	1	PAGERTEC COLOMBIA SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
535	19452822	2	PALACIOS MARTINEZ JAVIER	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
536	8903173392	1	PALLOMARO SA	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
537	800190654	1	PAPELERIA LOS COLORES SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
538	900810766	1	PATPUBLICIDAD SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
539	1130946922	2	PATIÑO OSPINA EDUAR	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
540	901551261	1	PARADISO FOOD GARDEN SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
541	1423211	2	PAREDES FREITEZ CARLOS RAUL	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
542	39687252	2	PARIS LEON CLAUDIA MARIA	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
543	1151949539	2	PARRA LUGO KEVIN STEC	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
544	1144104675	2	PARRAGA OCAMPO LUISA MARIA	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
545	66994552	2	PARRA SANTACRUZ LUZ MARINA	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
546	16768723	2	PARRA VEGA ADOLFO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
547	61026941	2	PARRA VARGAS KIM VALAR	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
548	9014571965	1	PARTNER CERTIFICATION COLOMBIA SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
550	1151955496	2	PAVON FRANCO KEVYN	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
551	901504718	1	PC OFFICE DIGITAL SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
552	8050129210	1	PATRIMONIOS AUTONOMOS ACCION FIDUCIARIA	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
504	16844488	2	PERDIGON EDER ALEIXO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
553	94524473	2	PELAEZ  MAYA GABRIEL	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
554	1105362513	2	PERDOMO CLAVIJO SANTIAGO	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
555	1144183220	2	PEREZ SOLIS NAZLY	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
556	1130633128	2	PINZON CASTILLO OSCAR IVAN	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
557	900733660	1	PLM INTERNACIONAL SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
558	805014351	1	PALSTICAUCHOS COLOMBIA SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
559	8001603500	1	PLANTOTAL CONSULTORIA Y PROYECTOS INMOBILIARIOS LT	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
560	900013664	1	PLATAFORMA COLOMBIA SAS	2026-07-24 13:43:19	2026-07-24 13:43:19	\N
561	901318939	1	PLAZA IMPRESORES SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
562	1144139152	2	PLAZA LEIDY TATIANA/ COMERCIALIZADORA ALIADA DEL VALLE	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
563	1112481402	2	PITO BEDON RUBEN DARIO	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
564	94425361	2	POLANIA CAICEDO JHON ALEXANDRE	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
565	860013720	1	PONTIFICIA UNIVERSIDAD JAVERIANA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
566	9013738881	1	POP PLUS SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
567	8600013174	1	PUBLICAR	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
568	900867997	1	PRACTIGUANTES JC SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
569	1087107137	2	PRECIADO PRECIADO INGRITH PAOLA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
571	900150916	1	PRODUCTOS SICURO SOCCIEDAD POR ACCIONES SIMPLIFICADA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
572	900052749	1	PRODUCTOS MAXILIMPIO EU	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
573	900539922	1	PRO CLEANER SERVICE SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
574	901076334	1	PROFINVEST DEL VALLE SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
575	8300837281	1	PROMIX	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
576	8300536918	1	PROMOVALLE	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
577	900374172	1	PROQUIM INDUSTRIAL SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
578	901789065	1	PROYECTO GLASS SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
579	9009257747	1	PROYECCION HUMANA INTERNACIONAL	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
580	901079204	1	QP HOTELES SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
581	9008590532	1	QUALITYCHECK SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
582	66824781	1	QUINTERO CARRILLO ESPERANZA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
583	16739500	2	QUINTERO CARRILLO FERNANDO LEON	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
584	16679818	2	QUINTERO CARRILLO HECTOR CESAR	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
585	31309871	2	QUINTERO MOSQUERA VIVIANA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
586	1144146636	2	QUINTERO VALENCIA CHRISTIAN KEVIN- HOME BLINDS CORTINAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
587	8050259611	1	QUESOS LA FLORIDA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
588	9006777323	1	QI ENERGY	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
590	14991258	2	RAMIREZ FULVIO EDUARDO	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
591	1000397353	2	RAMIREZ GALLEGO JUAN ESTEBAN	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
592	16746359	2	RAMIREZ MARTINEZ DANILO	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
593	31283288	2	RAMIREZ SANCHEZ MARIA ELENA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
594	9008438989	1	RAPPI SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
595	8300940219	1	RHT DIAGNOSTICO Y SOLUCIONES	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
596	1007914313	1	REALPE ARCOS JUAN JOSE	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
597	1144083709	2	RESTREPO PAREDES MARIA JULIANA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
598	31324120	2	RETAYUD MAYA MARIA ANTONIA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
599	800192105	1	RECORDAR	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
600	805008041	1	REFRIMAG SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
601	16630920	2	REFRIGERACION VALDES	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
602	9009397984	1	RENTING AUTOMAYOR SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
603	1059910815	2	RIOS MUÑOZ DIDIER ADOLFO	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
604	31953797	2	ROCALES Y CONCRETOS SOCIEDAD POR ACCIONES	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
605	14839010	2	ROMAN ARBOLEDA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
606	830107719	1	ROSAS DON ELOY SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
607	1144198365	2	RUBIANO JEFREY	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
608	16739501	2	RUIZ WILSON	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
609	1130612436	2	RUIZ WILSON	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
610	66712602	2	ALEIDA RIOS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
589	900984098	1	RG ALTURAS SALUD Y SEGURIDAD	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
612	94472016	2	RIVERA ANDRADE JULIO MAURICIO	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
613	16613656	2	RIVERA PELAEZ JUAN JAIRO	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
614	52268577	2	RIVERA PEREZ SANDRA MILENA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
615	39792186	2	RIVERO CASTRO CLAUDIA PATRICIA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
616	8050273951	1	ROBLEDO SARRIA SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
617	901405197	1	RODANDO LOGISTICA Y MENSAJERIA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
570	900319753	1	PRICESMART COLOMBIA SAS	2026-07-24 13:43:20	2026-07-24 14:12:15	\N
618	29124822	2	RODRIGUEZ CARRILLO FRANCY LILIANA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
619	24334445	2	RODRIGUEZ MORENO ADRIANA PATRICIA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
620	31569142	2	RODRIGUEZ MURILLO SANDRA DEL PILAR	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
621	1130591273	2	ROMERO VILLOTA CARLOS SALOMON	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
622	1000378231	2	ROJAS JIMENEZ DIQUEL STEVEN	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
623	1144024140	2	ROJAS SUAREZ JUAN CAMILO	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
624	800051232	1	RUSSELL BEDFORD RBG SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
625	901236470	1	RVSTIMENTO SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
627	900157270	1	SS COLOMBIA SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
628	9004364389	1	SAGIR DOTACIONES Y PUBLICIDAD SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
629	31484297	2	SALAZAR PORTILLA PAULA ANDREA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
630	900458352	1	SALUD ABLE FOODS SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
631	14696334	2	SALDARRIAGA PAEZ JULIAN ANDRES	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
632	16677304	2	SANDOVAL REBOLLEDO ROBINSAON	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
633	1130606349	2	SANCHEZ ALVAREZ ALEJANDRO	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
634	16680039	2	SANCHEZ BELTRAN EDGAR RAFEL	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
635	1064437513	0	SANCHEZ CAMPO GEISON STHIVEN	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
636	80145012	2	SANCHEZ CASCANTE EDDER LEANDO	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
637	1130635306	2	SANCHEZ LOAIZA KELLI ALEJANDRA	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
638	14443795	2	SANCHEZ ZORRILLA HUGO	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
639	16682047	2	SANCHEZ DORADO JAMES	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
640	66924768	2	SANCHEZ ESPINOSA FRANCISCO	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
641	9005256165	1	SANEAMIENTO AMBIENTAL SAS	2026-07-24 13:43:20	2026-07-24 13:43:20	\N
642	1006050172	2	SANTACRUZ MORALES OSCAR DANIEL	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
643	31629170	2	SALCEDO SOSA VOCTORIA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
644	830092741	1	SARMIENTO SANTAMARIA JORGE EDWARDO	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
645	1005969030	2	SARRIA RODRIGUEZ VALERIA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
646	805013122	1	SAUCEDO Y SAUCEDO	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
647	31582096	2	SEGURA GILBERTO	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
648	890903407	1	SEGUROS GENERALES SURAMERICANA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
649	8909037905	1	SEGUROS DE VIDA SURAMERICANA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
650	900472949	1	SEGURIDAD INDUSTRIAL Y MEDICA SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
651	901040928	1	SEGURIDAD CON ALTURAS SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
652	830053812	1	SEGURIDAD ONCOR LTDA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
653	890101272	1	SEMPERTEX DE COLOMBIA SA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
654	890310455	1	SERCOFUNLTDA FUNERALES LOS OLIVOS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
655	9002843656	1	SERVICIO DE SALUD INMEDIATO	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
656	9014452266	1	SERVICIOS DE MANTENIMIENTOS Y SOLUCIONES DFP SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
657	900139082	1	SERVICIO EMPRESARIAL IT ITSE SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
658	900266402	1	SERVICIOS INTEGRADOS COLUMBIA TECNOLOGIA SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
659	1130672772	2	SERVICIOS Y ASESORIOS PASARELA DEL VALLE	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
660	9005831471	1	S I SISTEMAS INFORMATICOS Y TECNOLOGIA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
661	890319193	1	SISTEMA DE INFORMACION EMPRESARIAL	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
662	9009514631	1	SISTEMAS INDUSTRIALES Y SEGURIDAD OCUPACIONAL	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
663	9006771094	1	SISTEMAS AUTOMATICOS DEL VALLE	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
664	9011767911	1	SOGNI FOODS SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
665	9001405400	1	SOFWARE DE INNOVACION	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
611	59705595	1	SOLARTE ERAZO GRACIELA	2026-07-24 13:43:20	2026-07-24 13:43:21	\N
666	1144056807	2	SOLIS ARBOLEDA MILLER ALEXANDRES	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
667	9009494190	1	SOLUCIONES INTEGRALES	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
668	800135441	1	SOLUCIONES FOURGEN SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
669	900753803	1	SOUTH AMERICA TECH S LUTIONS SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
670	94524200	1	SOTO JUIO CESAR	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
671	16664063	2	SOTO BEDOYA JAIME	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
672	9004714900	1	STI SOLUCIONES TECNOLOGICAS INTEGRALES DE COLOMBIA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
673	16680170	2	SUAREZ ESCOBAR DIEGO	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
674	94372963	2	SUAREZ LOZADA JORGE HERNAN	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
675	9007486424	1	SUMAR PRODUCTIVIDAD SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
676	900405827	1	SURTIR DE OCCIDENTE SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
677	8000875655	1	SYNLABCOLOMIA SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
678	16749883	2	TABARES FARIETA GERMAN	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
679	1144158114	2	TALLER FULL VISION	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
680	901092430	1	TANK CARE SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
681	8600000064	1	TEAM FOODS COLOMBIA S.A.	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
682	1144074773	2	TAPASCO VELASQUEZ SALOMON	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
683	9001633166	1	TECNOLOGIA EN SISTEMAS DE INFORMACION TSI	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
684	901277060	1	TECSOPACK CL SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
428	1118295726	2	TENORIO COLLAZOS LISSETH	2026-07-24 13:43:18	2026-07-24 13:43:21	\N
685	94427626	2	TENORIO ESCOBAR  ANDRES MAURICIO	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
686	890328298	1	TELEVICENTRO DEL VALLE SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
687	9008904463	1	TIANSHI SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
688	900334659	1	TIENDA PORTABLE SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
689	8050178761	1	TIEMPOS Y ESPRACIOS SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
690	1144140629	2	TOMBE CHAMORRO VANESSA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
691	94509014	2	TORRES CARDENAS EDGAR ALFREDO	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
692	1086044923	2	TORRES SINISTERRA LUZ MAYRA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
693	48659980	2	TORRES TABARES JENNY	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
694	45584433	2	TORRES VARGAS ANA CAROLIN	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
695	1081421304	2	TORRES Daniela	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
696	890935900	1	TOSTADITOS SUSANITA SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
697	900914813	1	TOTAL AIRES SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
698	9005013927	1	THOTAL PRINTER SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
699	901828562	1	TU PIN SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
700	9012419647	1	THNK ENGLIS EDITORIAL SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
701	901824517	1	THE BOX TECHNOLOGY SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
702	900059124	1	THT THE TALENT SYSTEM SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
703	900390126	1	THE FACTORY HKA COLOMBIA SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
704	29568043	2	TREJOS TABORDA MARTHA  LICED	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
705	1144145140	2	TROCHEZ PUCHANA WILLIAM	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
706	8050062147	1	TRULY NOLEN	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
707	31929862	2	TRUJILLO MOSQUERA ROSMERY	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
708	9006371624	1	UBERLINK COLOMBIA SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
709	9002621196	1	UNIDAD MEDICA VISUAL CALI	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
710	8903167455	1	UNIVERSIDAD ICESI	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
711	8903074001	1	UNIVERSIDAD SAN BUENAVENTURA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
712	8903109035	1	UNICUCES	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
713	900418685	1	VALIDA SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
714	94315075	2	VALENCIA GARCIA JOSE ALEXANDER	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
715	1144160117	2	VALENCIA SANTACRUZ LITHNYBED PAMELA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
716	1143947231	2	VALECIA CABEZAS ISABELLA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
717	901145498	1	VALOR DE MARCAS SAS	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
718	1113661477	2	VALOR RIVERA CHEISTIAN	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
719	1143879454	2	VALLEJO FLOR LINA MARCELA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
720	66924377	2	VALLEJO FARINANGO MYRIAM LUCIA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
721	10019052	2	VARGAS DIAZ ALEXANDER	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
722	1113692094	1	VARGAS HENAO SILVANA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
723	94370657	2	VARGAS PARRA JULIAN ALBERTO	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
724	38604463	2	VELASQUEZ CAMELO DIANA	2026-07-24 13:43:21	2026-07-24 13:43:21	\N
725	1118309911	2	VELASCO MUÑOZ GISEL NATALIA	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
726	14651902	2	VELASQUEZ HENAO GUSTAVO ADOLFO	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
727	109874793	2	VELAZQUEZ SALAS EMILIO JOSE	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
728	900819820	1	VELEZ IMPORT TRADING SAS	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
729	1112488201	1	VELEZ VERGARA LAURA VANESSA	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
730	16762002	2	VERGRA MESA GERARDO ALEZANDER	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
731	16944689	2	VERTICAL ANDAMIOS	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
732	1144188081	2	VIAFARA OCHOA ANA MARIA	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
733	900384450	1	VICBAY SAS/ nuevo proveedor de uniformes / nueva cuta mes julio 2024	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
734	9003844503	1	VICBAY SAS	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
735	1144192780	2	VICUÑA GOMEZ JESSIE	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
736	316291708	2	VICTORIA SALCEDO SOSA	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
737	16724138	2	VICTOR HUGO POLANCO SOLARTE	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
738	1151955710	2	VIDAL MELO VIVIANA CAROLINA	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
739	890311168	1	VIDRIOS DE OCCIDENTES SAS	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
741	6098339	2	VILLANUEVA ARIAS JOSE ALEXANDER	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
742	31892812	2	VILLAMIL MOSQUERA DORA PATRICIA	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
743	901018886	1	VIVE TU SAS	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
744	9011902775	1	VOZIP BUSINESS OF TECHNOLOGY SAS	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
745	830135533	1	WHITING DOOR COLOMBIA SAS	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
746	9013377232	1	WALF CONSULTORES SAS	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
747	66835978	2	YEPES YEPES CLAUDIA	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
748	1143867588	2	YUSTY ROJAS DANIELA	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
749	17028892	2	ZAMBRANO CALDERON FRANCISCO	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
750	1130620140	2	ZULUAGA QUINTERO LEIDY JOHANA	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
751	1112498512	2	ZAPATA VIVAS DANIELA	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
752	34513048	2	ZULUAGA ESQUIVEL BEATRI EUGENIA	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
753	16882056	2	ZULUAGA GUILLERMO	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
754	66678105	2	JHAQUELINE GARCIA	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
755	67032443	2	JENNIFER MAURE	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
756	1144193247	2	DANIELA MASABEL	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
757	1143989751	2	SANCHEZ CUERO YONATHAN	2026-07-24 13:43:22	2026-07-24 13:43:22	\N
243	8909177802	1	ELECTROQUIMICA WEST S.A	2026-07-24 13:43:16	2026-07-24 13:49:43	ELECTROQUIMICA WEST SA
390	9004225949	1	INVERSIONES VIVE AGRO S.A.S	2026-07-24 13:43:17	2026-07-24 13:57:39	INVERSIONES VIVE AGRO SAS
549	900964881	1	PARROQUIA NUESTRA SEÑORA DE LA RECONCILI	2026-07-24 13:43:19	2026-07-24 13:58:38	PARROQUIA NUESTRA SEÑORA DE LA RECONCILIACION
740	8600341187	1	VILASECA S.A.S.	2026-07-24 13:43:22	2026-07-24 14:05:04	VILASECA SAS
626	901006683	1	SACOTTO - CAGIGAS S.A.S.	2026-07-24 13:43:20	2026-07-24 14:09:05	SACOTTO
164	8600002616	1	COMPANIA NACIONAL DE LEVADURAS LEVAPAN S	2026-07-24 13:43:15	2026-07-24 14:11:19	COMPAÑÍA NACIONAL DE LEVADURAS
758	1005744761	2	OTERO ALBARRACIN SALVATORE	2026-07-24 14:18:49	2026-07-24 14:18:49	\N
293	8909039395	1	POSTOBON SA	2026-07-24 13:43:17	2026-07-24 14:25:21	GASEOSAS POSADA TOBON SA
83	9006079700	1	MES GROUP SAS UNICENTRO	2026-07-24 13:43:14	2026-07-24 14:30:55	MES GROUP UNICENTRO
\.


--
-- Data for Name: third_party_bank_accounts; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.third_party_bank_accounts (id, third_party_id, bank_id, account_number, account_type, is_primary, is_active, created_at, updated_at) FROM stdin;
51	56	5	80303677791	CC	f	t	2026-07-24 13:43:14	2026-07-24 13:43:15
28	34	5	17864251442	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:15
6	12	5	8450440958	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
7	13	5	9800002360	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
8	14	5	6611826492	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
9	15	4	16660020013	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
10	16	6	32354060	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
11	17	5	4803652711	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
12	18	5	18500006926	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
13	19	5	75752900710	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
14	20	5	82500000314	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
15	21	5	7741249914	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
16	22	4	450870023733	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
17	23	5	71037089502	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
18	24	5	81039785362	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
20	26	5	91212330847	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
21	27	5	75710958211	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
22	28	4	15969998689	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
23	29	5	30375270008	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
24	30	6	391437829	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
25	31	8	3053129888	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
26	32	4	108900048308	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
27	33	5	81313101436	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
29	35	4	16090718251	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
31	37	4	10170072390	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
32	38	5	6043804241	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
33	39	5	7700933327	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
36	42	4	46500068161	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
37	43	5	7743035971	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
38	44	10	315000802	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
39	45	4	1969998648	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
40	46	4	10470049270	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
66	71	9	1153816	CC	f	t	2026-07-24 13:43:14	2026-07-24 13:43:15
30	36	9	19907518	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
41	47	4	10270093320	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
42	48	4	35169997919	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
43	49	7	382013878	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
35	41	5	82525890330	CA	f	t	2026-07-24 13:43:14	2026-07-24 13:43:14
44	41	5	82521927150	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
45	50	4	550016800071280	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
46	51	5	6200010149	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
47	52	5	74563364304	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
48	53	5	7953313060	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
49	54	5	71693779655	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
50	55	4	15370004747	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
52	57	5	30090864132	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
54	59	11	61054014	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
55	60	4	488408947635	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
56	61	6	484737242	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
57	62	6	484802616	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
58	63	4	16160013658	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
59	64	5	82500004463	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
60	65	9	15053788	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
61	66	5	80700002920	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
62	67	5	30400122779	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
63	68	5	51427359561	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
64	69	4	550006200258249	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
65	70	5	5256000134	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
67	72	5	82100003713	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
68	73	6	566195715	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
69	74	5	82900010678	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
70	75	5	80800054072	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
71	76	4	46269999275	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
73	78	4	570007170661982	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
72	77	4	15369998552	CC	f	t	2026-07-24 13:43:14	2026-07-24 13:43:14
74	77	4	7169994022	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
76	80	4	470100424782	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
77	81	9	1799949	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
78	82	12	999001002	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
81	85	13	10301810606	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
82	86	5	91200411841	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
83	87	5	3175544509	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
84	88	4	12769993523	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
34	40	4	17269993915	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:43:16
75	79	9	77843654	CA	f	t	2026-07-24 13:43:14	2026-07-24 13:43:18
80	84	10	314087125	CA	f	t	2026-07-24 13:43:14	2026-07-24 13:43:20
5	11	5	80800009803	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:21
19	25	7	487003030	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:45:52
53	58	4	1869997690	CC	t	t	2026-07-24 13:43:14	2026-07-24 13:46:28
4	10	4	16090296928	CA	t	t	2026-07-24 13:43:05	2026-07-24 14:18:49
79	83	10	314037835	CA	f	t	2026-07-24 13:43:14	2026-07-24 14:30:55
85	89	5	26551661546	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
86	90	5	82100007778	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
87	91	5	7725992119	CA	t	t	2026-07-24 13:43:14	2026-07-24 13:43:14
88	92	14	5033656027	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
89	93	9	25880071	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
90	94	4	10469998339	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
91	95	5	65084685199	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
92	96	6	487217820	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
93	97	5	6269801121	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
94	98	5	73796065718	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
95	99	4	15570083657	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
96	100	6	486581630	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
97	101	4	17570101430	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
98	102	6	605300722	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
99	103	5	82100000613	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
101	105	5	81269517743	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
102	106	5	20305001485	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
103	107	4	488449402699	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
104	108	9	1527100	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
105	109	5	81352516368	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
106	110	4	0570018570117889	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
107	111	5	75253898186	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
109	113	5	26544872671	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
110	114	5	80852242021	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
111	115	4	4030236964	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
112	116	5	32600437911	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
113	117	14	501031720	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
114	118	5	71600002649	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
115	119	5	7787261102	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
116	120	5	91245324583	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
117	121	9	1131275	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
118	122	5	85826545882	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
119	123	5	6120771203	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
120	124	4	16000998738	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
121	125	5	71659994245	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
122	56	4	17860006711	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
123	126	4	17570071864	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
124	127	5	30380870252	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
126	129	4	15569999848	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
128	131	5	60512131321	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
129	132	14	5123079029	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
130	133	5	67511576854	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
131	134	5	75068786215	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
132	135	4	560017260003250	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
133	136	5	82968405680	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
134	137	4	379400001028	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
135	71	5	60408812263	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
136	138	15	395014939	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
137	139	5	74958938290	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
138	140	15	234109338	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
139	141	5	82906762791	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
140	142	5	82979651143	CA	f	t	2026-07-24 13:43:15	2026-07-24 13:43:15
141	142	6	486317134	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
142	143	5	83780295281	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
143	144	6	869015537	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
145	146	5	82500005181	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
146	147	5	80300022913	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
147	148	5	30375000223	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
148	149	6	249183328	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
149	150	14	5982000360	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
151	152	4	10170045750	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
152	153	4	10170045768	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
153	154	5	26500001342	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
154	155	5	73513432591	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
155	156	5	74966958352	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
156	157	4	560009469998588	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
157	158	9	22035356	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
158	159	9	14067052	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
159	160	7	101124105	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
160	161	5	51439913157	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
161	162	5	81200001605	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
162	163	5	82957496314	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
164	165	5	81300013325	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
165	166	5	22903374131	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
166	167	16	170018454271	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
167	168	6	486750870	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
168	169	6	484210703	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
169	170	5	73688179332	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
170	171	5	82500004960	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
171	172	15	502004799	CC	t	t	2026-07-24 13:43:15	2026-07-24 13:43:15
172	173	9	24812810	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
173	174	5	3900732705	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
174	175	5	30051522190	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
127	130	5	26500006479	CA	f	t	2026-07-24 13:43:15	2026-07-24 13:43:20
150	151	4	17500025238	CA	f	t	2026-07-24 13:43:15	2026-07-24 13:43:16
125	128	4	15300007190	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:17
100	104	5	82524522094	CA	t	t	2026-07-24 13:43:15	2026-07-24 13:43:18
144	145	4	9022308488	CA	t	t	2026-07-24 13:43:15	2026-07-24 14:06:04
163	164	5	17157157600	CC	t	t	2026-07-24 13:43:15	2026-07-24 14:11:19
108	112	7	165004110	CA	t	t	2026-07-24 13:43:15	2026-07-24 14:24:14
176	177	5	38107153567	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
177	178	9	45029766	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
179	180	4	12700056463	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
180	181	4	488447197473	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
181	182	15	927202283	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
182	183	5	75010845807	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
183	184	14	3002818620	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
184	185	5	7798433053	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
186	187	5	75737089631	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
187	188	5	80880349591	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
188	189	5	80722251242	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
189	190	5	51452317137	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
190	191	5	30375392221	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
191	192	4	488401161523	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
192	193	5	82100004408	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
193	194	5	30075149139	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
194	195	4	488416077680	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
195	196	5	25500000528	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
196	197	5	81249406856	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
197	198	5	6074207314	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
198	199	4	17270273927	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
199	200	15	916005026	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
200	201	9	45035722	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
201	202	5	37854427640	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
202	203	5	81200012883	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
203	204	5	69381840418	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
204	205	5	6200000222	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
206	207	5	82347480218	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
207	208	5	80813892881	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
208	209	6	166341958	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
209	210	5	80724201481	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
210	211	4	17969999352	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
211	212	6	158081695	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
212	213	15	977000298	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
213	214	6	458670999	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
214	215	17	24086502621	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
215	216	4	560036569999398	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
216	217	5	74950111295	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
218	219	15	813022472	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
219	220	4	550016600691485	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
220	221	15	583008974	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
221	222	5	91200217735	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
222	223	9	1863844	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
223	224	5	75041173157	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
224	225	5	91279463001	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
225	226	4	16400658916	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
226	227	6	486544992	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
227	228	14	911000415	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
228	229	5	82531922970	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
229	230	11	5062840023	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
230	231	5	91238536907	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
231	232	4	488408611686	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
232	233	5	20518417658	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
233	234	5	6000821328	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
234	235	5	68917909893	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
235	151	4	17560004289	CC	f	t	2026-07-24 13:43:16	2026-07-24 13:43:16
236	151	9	42851816	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
237	236	4	452900109615	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
238	237	5	6232363508	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
239	238	4	16869998936	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
240	239	5	7700001848	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
241	240	5	75087151312	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
243	242	17	26503084136	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
245	244	9	1069418	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
246	245	5	4012678507	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
247	246	5	6020559709	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
248	247	5	88512160489	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
249	248	9	25038654	CC	f	t	2026-07-24 13:43:16	2026-07-24 13:43:16
250	248	4	16500068206	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
252	250	5	6200052207	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
253	251	5	80358093692	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
254	252	5	80327543789	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
255	253	5	600000171	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
256	254	4	550108900596470	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
257	255	5	23100001072	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
258	256	5	6280229952	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
260	258	6	146410022	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
261	259	4	26869998794	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
262	260	4	17570029680	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
242	241	4	550488426517501	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:18
178	179	5	82368434716	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:19
217	218	5	7700003522	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:20
251	249	4	10470063412	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:22
205	206	4	9020035106	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:48:43
244	243	4	38469999049	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:49:43
185	186	5	62179643117	CA	t	t	2026-07-24 13:43:16	2026-07-24 14:03:55
259	257	9	1208073	CC	t	t	2026-07-24 13:43:17	2026-07-24 14:09:57
175	176	4	488407287272	CA	t	t	2026-07-24 13:43:16	2026-07-24 14:13:23
263	261	5	6030321503	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
264	262	5	5310171117	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
265	263	17	24077742742	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
266	264	5	6000023403	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
269	267	4	108900379489	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
271	269	9	15065154	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
272	270	5	6222857241	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
273	271	5	83600006051	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
274	272	5	83753509336	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
275	273	17	21004449589	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
276	274	5	20035806254	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
277	275	6	146541040	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
278	276	5	10042566361	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
279	277	5	6430657280	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
280	278	4	17200146813	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
281	279	5	81230958941	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
282	280	18	220580188019	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
283	281	4	16869996633	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
284	282	5	77383853916	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
285	283	6	427041173	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
286	284	5	30685193545	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
287	285	5	69429780349	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
288	286	5	30411243529	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
289	287	15	243057981	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
290	288	5	82908355969	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
291	289	4	16500676776	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
292	290	4	17270255270	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
293	291	5	91277450653	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
296	294	5	82546093146	CA	f	t	2026-07-24 13:43:17	2026-07-24 13:43:17
297	294	4	16160014631	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
298	295	13	10301187706	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
299	296	5	71655680009	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
300	297	5	75251154040	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
301	298	5	81200000799	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
302	299	4	18069999094	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
303	300	7	148779171	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
304	301	5	75067239954	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
305	302	5	74986113693	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
306	303	5	5955366991	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
307	304	4	0550015700063819	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
309	306	15	861000487	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
310	307	5	91212048963	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
311	308	15	875003357	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
312	309	5	91236165391	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
313	310	17	24056198184	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
314	311	5	74155884464	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
315	312	5	30041507824	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
316	313	5	71641547021	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
317	314	14	5882027028	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
318	315	5	6172605859	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
319	316	4	3168076864	DP	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
320	317	4	17570057517	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
321	318	5	51483733317	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
322	319	5	19127831745	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
323	320	5	82308604554	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
324	321	5	80745892152	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
325	322	5	80733615064	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
326	323	4	488405627313	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
327	324	5	83600002129	CA	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
328	325	5	6100005633	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
329	326	6	249324666	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
330	327	4	16769999604	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:43:16
332	329	4	17969996002	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
333	330	5	86000011801	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
334	331	5	81000004791	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
335	332	6	256361221	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
336	333	4	550016000449807	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
337	334	7	140002650	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
338	335	5	30381175664	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
339	336	15	616004123	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
340	337	15	502006919	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
341	338	5	4829183069	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
342	339	9	77843399	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
343	340	5	81305037337	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
344	341	4	0550488445001685	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
345	342	15	230003642	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
346	343	6	146329669	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
347	344	5	6893583732	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
348	345	7	123928140	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
349	346	5	73529376721	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
350	347	5	91212553676	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
351	348	5	81500000414	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
352	349	4	550488412581099	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
268	266	4	470160032780	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
270	268	9	23835648	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:19
295	293	6	226431963	CA	t	t	2026-07-24 13:43:17	2026-07-24 14:25:21
267	265	5	81084014028	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:50:25
308	305	4	2469999482	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:51:23
331	328	4	10269986476	CC	t	t	2026-07-24 13:43:16	2026-07-24 13:53:01
294	292	14	5842000688	CA	t	t	2026-07-24 13:43:17	2026-07-24 14:16:33
353	350	5	26576735510	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
354	351	5	81571879878	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
355	352	5	13508862290	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
356	353	5	83600021420	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
357	354	5	80700010353	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
358	355	17	24042855628	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
359	356	15	833000836	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
360	357	5	30400000656	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
361	358	5	82597638406	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
362	359	5	80380833411	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
363	360	5	30011190790	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
364	361	6	486488661	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
365	362	5	82100028723	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
366	363	6	470240458	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
367	364	17	24101342906	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
368	365	5	82106733493	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
369	366	6	9403775	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
370	367	5	6221777636	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
371	368	6	134334242	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
372	369	5	74943787127	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
431	425	4	10469997539	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
374	370	5	22903370847	CA	f	t	2026-07-24 13:43:17	2026-07-24 13:43:17
373	370	5	22934633214	CA	f	t	2026-07-24 13:43:17	2026-07-24 13:43:17
375	370	5	22930010760	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
376	371	5	81511437766	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
377	372	5	6100003038	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
379	374	5	6004971179	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
380	375	18	567130356	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
381	376	5	82914132154	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
382	377	4	15500034713	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
383	378	5	71600003842	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
384	379	5	81228101354	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
385	380	5	4701233609	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
386	381	4	15100009891	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
387	382	5	6413273287	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
388	383	5	80362930448	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
389	384	5	80869899375	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
390	385	9	12880258	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
391	386	4	26869998778	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
392	387	4	17269995092	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
393	388	4	10469997232	CC	f	t	2026-07-24 13:43:17	2026-07-24 13:43:17
394	388	4	10469997448	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
395	389	5	71600003906	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
397	391	5	26573614304	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
398	392	5	43229853313	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
399	393	5	82505460657	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
400	394	5	7700009143	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
401	395	5	6498324400	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
402	396	15	813001613	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
403	397	15	977015122	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
404	398	5	84800031736	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
405	399	5	20508315202	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
406	400	4	570018570117418	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
407	401	5	82913782417	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
408	402	5	80722485126	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
409	403	4	16569997410	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
411	405	5	6267429845	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
412	406	5	74900000742	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
413	407	5	3186177037	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
414	408	5	82919801752	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
415	409	4	108900126484	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:43:17
416	410	9	10071447	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
417	411	5	7739265368	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
418	412	5	80717851646	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
419	413	5	73436117652	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
420	414	6	470142332	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
421	415	4	488438274984	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
422	416	4	450770065198	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
423	417	5	4241294559	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
424	418	5	6200001250	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
425	419	5	75000003515	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
426	420	5	33500004896	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
427	421	5	82962710990	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
428	422	5	77455762548	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
429	423	5	80813168310	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
430	424	4	10469996739	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
433	426	5	6430684383	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
434	427	14	5851005783	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
436	429	4	570017270207891	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
432	425	4	10469997059	CC	f	t	2026-07-24 13:43:18	2026-07-24 13:43:18
437	430	4	550016800097590	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
438	431	5	18540633785	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
439	432	5	6954092699	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
440	433	9	29881307	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
441	434	5	84893961746	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
442	435	5	81204940590	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
378	373	5	12610660873	CC	t	t	2026-07-24 13:43:17	2026-07-24 13:55:27
396	390	17	24143066996	CA	t	t	2026-07-24 13:43:17	2026-07-24 13:57:39
410	404	5	6031162502	CC	t	t	2026-07-24 13:43:17	2026-07-24 14:07:29
443	436	5	75005975697	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
444	437	15	230236747	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
445	438	5	30015184751	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
446	439	5	71681624893	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
447	440	5	82500000565	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
448	441	5	71600004830	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
449	442	5	81370202192	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
450	443	4	12200048192	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
451	444	5	80800048561	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
452	445	5	82500004849	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
453	446	4	482869998088	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
454	447	4	15970079982	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
456	449	15	19008325	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
457	450	5	72227020963	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
459	452	14	502018230	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
460	453	5	82500004115	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
462	455	4	570015170013419	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
458	451	6	84026285	CC	f	t	2026-07-24 13:43:18	2026-07-24 13:43:18
463	451	9	285021259	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
464	456	5	81200000413	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
465	457	5	51499813817	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
466	458	4	15900004761	CA	f	t	2026-07-24 13:43:18	2026-07-24 13:43:18
467	458	4	16090733821	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
468	459	5	6283165656	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
469	460	4	108900277121	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
470	461	6	166319947	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
471	462	6	470069451	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
472	463	5	71600001762	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
473	464	4	17500032838	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
474	465	5	51483711321	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
475	466	5	7794004808	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
476	467	5	99193981735	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
477	468	5	83679322071	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
478	469	5	81000016934	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
479	470	5	6500350837	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
480	471	9	25054230	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
481	472	5	74595213863	CC	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
482	473	6	249371782	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
483	474	4	10100047173	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
484	475	4	10100047165	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
455	448	15	230411571	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:19
500	481	5	30445150272	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
501	482	4	560004369995198	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
502	483	4	17600033553	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
503	484	5	80700022921	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
504	485	9	1133578	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
505	486	5	7744432957	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
506	487	4	3113741332	DP	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
507	488	5	74155895067	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
523	504	4	550010400010186	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
461	454	5	82500020691	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:19
508	489	5	83793461803	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
509	490	6	146449673	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
510	491	5	82916637485	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
511	492	5	91262853794	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
512	493	5	71062737331	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
513	494	5	96795636983	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
514	495	17	24077484596	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
515	496	5	6500902919	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
516	497	5	6230266195	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
485	83	4	10169994042	CC	f	t	2026-07-24 13:43:18	2026-07-24 14:30:55
486	83	4	10100028124	CA	f	t	2026-07-24 13:43:18	2026-07-24 14:30:55
487	83	4	550379400003255	CA	f	t	2026-07-24 13:43:18	2026-07-24 14:30:55
488	83	4	10169995833	CC	f	t	2026-07-24 13:43:18	2026-07-24 14:30:55
493	79	4	10169995452	CA	f	t	2026-07-24 13:43:18	2026-07-24 13:43:18
494	79	4	17570076681	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
495	476	5	6000037953	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:18
496	477	17	24051606798	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
497	478	14	5952012596	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
498	479	4	16169997380	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
499	480	5	82516811966	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
517	498	5	20525704141	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
518	499	5	74900022640	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
519	500	4	17960010001	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
520	501	6	484774328	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
521	502	5	68999778619	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
522	503	5	51446680149	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
524	505	4	10470047431	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
525	506	5	80744912559	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
526	507	5	22589988349	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
527	508	5	91210056667	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
528	509	5	73612089679	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
529	510	5	80755754301	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
530	511	5	80322037695	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
531	512	17	24113264636	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
532	513	18	230290293224	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
533	514	17	24102121885	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
534	515	5	91202296390	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
535	516	5	51470874809	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
536	517	7	77045516	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
537	518	5	91250975711	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
538	519	4	16570371852	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
539	520	5	75053607195	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
540	521	15	520215955	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
541	522	17	21004213494	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
542	523	5	32671513249	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
543	524	5	74523281406	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
544	525	19	13871720	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
545	526	5	60539739754	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
546	527	5	73576763198	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
547	528	6	487387763	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
548	529	5	71025149381	CA	f	t	2026-07-24 13:43:19	2026-07-24 13:43:19
549	529	4	488447850253	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
550	530	4	15969998523	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
551	531	13	10505974501	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
552	532	5	71058843578	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
553	533	6	566672226	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
554	534	5	80876517192	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
555	535	5	74130563321	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
556	536	4	560379469999559	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
557	537	5	6007487112	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
558	538	5	6200011235	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
559	539	6	488148586	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
560	540	5	71600002348	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
561	541	5	6490300323	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
562	542	6	609009469	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
563	543	4	488414867058	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
564	544	4	550488409123269	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
565	545	5	74500003560	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
566	546	5	82980621690	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
567	547	5	74500017264	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
568	548	6	486638844	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
570	549	5	26500006518	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:58:38
571	550	8	3017573486	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
572	551	5	69300002026	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
573	552	9	1182526	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
574	553	5	30021476652	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
575	554	5	75024905616	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
576	555	5	81300000802	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
577	556	5	19555724368	CA	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
578	557	5	51425825672	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
579	558	5	6014282969	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
580	559	9	15865140	CC	t	t	2026-07-24 13:43:19	2026-07-24 13:43:19
581	560	5	30015259857	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
582	561	5	6200022899	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
583	562	5	82500000531	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
584	563	5	82573627560	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
585	564	14	1003577291	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
586	565	5	3100028661	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
587	566	4	15969998325	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
588	567	5	39421733034	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
589	568	5	66600012935	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
590	569	4	488457860648	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
592	571	13	30505464206	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
593	572	5	30075200256	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
594	573	5	80879403621	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
595	574	5	82177711230	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
596	575	5	19319199242	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
597	576	6	484802798	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
598	577	5	38125444205	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
599	578	5	60500010509	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
600	579	4	27569990503	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
601	580	5	71677351916	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
602	581	15	243019742	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
603	582	4	10460008369	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
604	583	4	10400011713	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
606	84	4	17560004818	CA	f	t	2026-07-24 13:43:20	2026-07-24 13:43:20
607	84	4	17570032932	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
608	585	4	0550017300128240	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
609	586	5	80885299681	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
610	130	5	26500001828	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
611	587	6	487293441	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
612	588	4	16069995302	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
614	590	5	6415709712	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
615	591	5	82100029002	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
569	549	5	26500006517	CA	f	t	2026-07-24 13:43:19	2026-07-24 13:58:38
613	589	5	81263544986	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
605	584	4	4035324430	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:22
591	570	5	65284955984	CC	t	t	2026-07-24 13:43:20	2026-07-24 14:12:15
616	592	14	502076582	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
617	593	5	30060854629	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
618	594	4	570006270545657	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
619	595	14	1000043725	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
620	596	5	60500045437	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
621	597	5	72235819300	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
622	598	5	80815418844	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
623	599	5	19208671357	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
624	600	5	81369314591	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
625	601	7	102926073	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
626	602	9	261861561	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
627	603	4	018570106502	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
628	604	6	486479108	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
629	605	5	75200000377	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
630	606	5	37221539894	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
631	607	4	570016170531848	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
632	608	9	1202431	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
633	609	4	550457400106086	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
634	610	5	60567545922	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
636	612	5	80812758469	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
637	613	5	91211743609	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
638	614	17	24109720113	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
639	615	4	6200401724	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
640	616	4	17369998194	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
641	617	5	74500001014	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
642	618	5	75289516654	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
643	619	5	82960553833	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
644	620	5	30075148801	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
645	621	5	82314819701	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
646	622	5	8485192337	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
647	623	5	74572576233	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
648	624	5	19343992607	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
649	625	5	26500012141	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
651	627	5	6436299727	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
652	628	4	10469997331	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
653	629	4	488447208528	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
655	631	8	3108250399	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
656	632	4	16300294325	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
657	633	5	81253812885	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
658	634	7	112097613	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
659	635	5	74159532791	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
660	636	4	550488412844711	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
661	637	5	6282754329	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
662	638	6	486430838	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
663	639	5	81048986030	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
664	640	5	74509034528	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
665	641	17	21003399629	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:20
666	642	5	91223277107	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
667	643	4	16970161077	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
654	630	5	82966006737	CC	t	t	2026-07-24 13:43:20	2026-07-24 13:43:21
668	644	5	20285725906	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
669	645	4	3127701535	DP	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
670	646	5	81044522321	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
671	647	14	6782002915	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
672	648	5	390127766	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
673	649	5	390088884	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
674	650	5	26575660788	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
675	651	5	83683573178	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
676	652	5	4000009496	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
677	653	5	40927330568	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
678	654	5	7715023037	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
679	655	6	566308482	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
680	656	4	15670083698	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
681	657	5	82541952256	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
682	658	5	75021216321	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
683	659	5	91200804231	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
684	660	4	477900053372	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
685	661	9	24005803	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
686	662	4	18569997705	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
687	663	5	6217088791	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
688	664	5	75093137477	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
689	665	9	480546399	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
650	626	5	71072402716	CC	t	t	2026-07-24 13:43:20	2026-07-24 14:09:05
635	611	7	142995625	CA	t	t	2026-07-24 13:43:20	2026-07-24 13:43:21
690	666	5	30015254104	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
691	667	4	12769994513	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
692	668	5	2913544105	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
693	669	15	578063695	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
694	670	14	1002261266	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
695	671	4	18060000843	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
696	672	6	164090367	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
697	673	5	6055235461	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
698	674	5	3053625858	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
699	675	6	484370598	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
700	676	7	138092051	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
701	677	4	30200032552	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
702	678	4	15160007546	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
703	679	17	24056415182	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
704	680	5	80781628747	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
705	681	4	6500243651	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
706	682	5	60511224643	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
707	683	9	1160464	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
708	684	5	75000026336	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
435	428	5	91201131931	CA	t	t	2026-07-24 13:43:18	2026-07-24 13:43:21
709	685	5	82959709510	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
710	686	5	80885863896	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
711	687	4	15370052563	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
712	688	5	82582451918	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
713	689	4	17500048594	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
714	690	5	91278674474	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
715	691	14	5872097854	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
716	692	4	488400322498	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
717	693	5	81355600921	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
718	694	4	18500042025	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
719	695	4	550015500013618	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
720	696	5	2993590005	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
721	697	5	82500004722	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
722	698	4	17969997331	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
723	699	5	15300004398	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
724	700	4	482300027067	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
725	701	5	10100004741	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
726	702	5	20272557331	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
727	703	5	70210684288	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
728	704	4	4025235162	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
729	705	7	127864176	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
730	706	9	73004145	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
731	707	6	249663543	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
732	708	17	21004271692	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
733	709	4	17369999184	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
734	710	9	42002832	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
735	711	9	1111921	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
736	712	6	19057520	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
737	713	5	18069890471	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
738	714	4	13400012079	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
739	715	4	488428639386	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
740	716	4	570012270069508	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
741	717	5	60500013994	CC	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
742	718	4	16370327070	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
743	719	5	91211555209	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
744	720	5	74547985048	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
745	721	4	488400809783	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
746	722	5	6605942138	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
747	723	4	488418700958	CA	t	t	2026-07-24 13:43:21	2026-07-24 13:43:21
748	724	5	91204673620	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
749	725	4	570018570115990	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
750	726	4	18570107880	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
751	727	14	5952017482	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
752	728	5	6238541451	CC	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
753	729	15	861093540	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
754	730	15	927072868	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
755	731	4	16670445416	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
756	732	4	488421815447	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
757	733	5	80348366941	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
758	734	4	17000183305	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
759	735	4	550488417596092	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
760	736	4	16970161077	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
761	737	4	16970167199	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
762	738	4	19170032163	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
763	739	5	6231116801	CC	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
765	741	5	91216102865	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
766	742	5	82919469478	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
767	743	5	81200004757	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
768	744	4	16570426946	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
769	745	5	89534138823	CC	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
770	746	4	16200691661	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
771	747	5	6200000997	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
772	748	6	249651969	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
773	749	5	75027098266	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
774	750	5	80811974963	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
775	751	5	71649107542	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
776	752	4	10470043828	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
777	753	5	71645792055	CC	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
778	754	4	17570064117	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
779	755	4	18570114340	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
780	756	4	488419327165	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
781	757	4	19470038472	CA	t	t	2026-07-24 13:43:22	2026-07-24 13:43:22
491	83	4	10169995825	CC	t	t	2026-07-24 13:43:18	2026-07-24 14:30:55
764	740	4	550009500057451	CA	t	t	2026-07-24 13:43:22	2026-07-24 14:05:04
782	758	6	475139473	CA	t	t	2026-07-24 14:18:49	2026-07-24 14:18:49
489	83	4	10100027225	CA	f	t	2026-07-24 13:43:18	2026-07-24 14:30:55
490	83	4	10169993366	CC	f	t	2026-07-24 13:43:18	2026-07-24 14:30:55
492	83	4	550379400003487	CA	f	t	2026-07-24 13:43:18	2026-07-24 14:30:55
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: payment_receipts
--

COPY public.users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at) FROM stdin;
6	Admin	admin@paymentmw.com	\N	$2y$12$FI/krMbRELF4dsXp/0RGRe0gKWM0UtJD8msHJMeews99yJAZ2st5u	4axCz5Rnqiupf4LRlCUmBXMkRUqG00FbIvPxXFCwbEJl7BUDUJTKMvmO56xX	2026-07-24 13:41:39	2026-07-24 13:41:39
\.


--
-- Name: bank_payment_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: payment_receipts
--

SELECT pg_catalog.setval('public.bank_payment_lines_id_seq', 168, true);


--
-- Name: banks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: payment_receipts
--

SELECT pg_catalog.setval('public.banks_id_seq', 19, true);


--
-- Name: branches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: payment_receipts
--

SELECT pg_catalog.setval('public.branches_id_seq', 17, true);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: payment_receipts
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: import_errors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: payment_receipts
--

SELECT pg_catalog.setval('public.import_errors_id_seq', 1, true);


--
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: payment_receipts
--

SELECT pg_catalog.setval('public.invoices_id_seq', 248, true);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: payment_receipts
--

SELECT pg_catalog.setval('public.jobs_id_seq', 1, false);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: payment_receipts
--

SELECT pg_catalog.setval('public.migrations_id_seq', 8, true);


--
-- Name: payment_batches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: payment_receipts
--

SELECT pg_catalog.setval('public.payment_batches_id_seq', 11, true);


--
-- Name: payment_receipts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: payment_receipts
--

SELECT pg_catalog.setval('public.payment_receipts_id_seq', 157, true);


--
-- Name: third_parties_id_seq; Type: SEQUENCE SET; Schema: public; Owner: payment_receipts
--

SELECT pg_catalog.setval('public.third_parties_id_seq', 758, true);


--
-- Name: third_party_bank_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: payment_receipts
--

SELECT pg_catalog.setval('public.third_party_bank_accounts_id_seq', 782, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: payment_receipts
--

SELECT pg_catalog.setval('public.users_id_seq', 6, true);


--
-- Name: bank_payment_lines bank_payment_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.bank_payment_lines
    ADD CONSTRAINT bank_payment_lines_pkey PRIMARY KEY (id);


--
-- Name: banks banks_code_unique; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.banks
    ADD CONSTRAINT banks_code_unique UNIQUE (code);


--
-- Name: banks banks_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.banks
    ADD CONSTRAINT banks_pkey PRIMARY KEY (id);


--
-- Name: branches branches_name_unique; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_name_unique UNIQUE (name);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);


--
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: import_errors import_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.import_errors
    ADD CONSTRAINT import_errors_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- Name: payment_batches payment_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.payment_batches
    ADD CONSTRAINT payment_batches_pkey PRIMARY KEY (id);


--
-- Name: payment_receipts payment_receipt_unique; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.payment_receipts
    ADD CONSTRAINT payment_receipt_unique UNIQUE (payment_batch_id, branch_id, receipt_number);


--
-- Name: payment_receipts payment_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.payment_receipts
    ADD CONSTRAINT payment_receipts_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: third_parties third_parties_document_number_unique; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.third_parties
    ADD CONSTRAINT third_parties_document_number_unique UNIQUE (document_number);


--
-- Name: third_parties third_parties_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.third_parties
    ADD CONSTRAINT third_parties_pkey PRIMARY KEY (id);


--
-- Name: third_party_bank_accounts third_party_bank_account_unique; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.third_party_bank_accounts
    ADD CONSTRAINT third_party_bank_account_unique UNIQUE (third_party_id, bank_id, account_number, account_type);


--
-- Name: third_party_bank_accounts third_party_bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.third_party_bank_accounts
    ADD CONSTRAINT third_party_bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: bank_payment_lines_payment_batch_id_nit_index; Type: INDEX; Schema: public; Owner: payment_receipts
--

CREATE INDEX bank_payment_lines_payment_batch_id_nit_index ON public.bank_payment_lines USING btree (payment_batch_id, nit);


--
-- Name: bank_payment_lines_payment_batch_id_payment_receipt_id_index; Type: INDEX; Schema: public; Owner: payment_receipts
--

CREATE INDEX bank_payment_lines_payment_batch_id_payment_receipt_id_index ON public.bank_payment_lines USING btree (payment_batch_id, payment_receipt_id);


--
-- Name: cache_expiration_index; Type: INDEX; Schema: public; Owner: payment_receipts
--

CREATE INDEX cache_expiration_index ON public.cache USING btree (expiration);


--
-- Name: cache_locks_expiration_index; Type: INDEX; Schema: public; Owner: payment_receipts
--

CREATE INDEX cache_locks_expiration_index ON public.cache_locks USING btree (expiration);


--
-- Name: failed_jobs_connection_queue_failed_at_index; Type: INDEX; Schema: public; Owner: payment_receipts
--

CREATE INDEX failed_jobs_connection_queue_failed_at_index ON public.failed_jobs USING btree (connection, queue, failed_at);


--
-- Name: import_errors_payment_batch_id_severity_index; Type: INDEX; Schema: public; Owner: payment_receipts
--

CREATE INDEX import_errors_payment_batch_id_severity_index ON public.import_errors USING btree (payment_batch_id, severity);


--
-- Name: invoices_payment_batch_id_causation_document_index; Type: INDEX; Schema: public; Owner: payment_receipts
--

CREATE INDEX invoices_payment_batch_id_causation_document_index ON public.invoices USING btree (payment_batch_id, causation_document);


--
-- Name: invoices_payment_batch_id_detail_document_number_index; Type: INDEX; Schema: public; Owner: payment_receipts
--

CREATE INDEX invoices_payment_batch_id_detail_document_number_index ON public.invoices USING btree (payment_batch_id, detail_document_number);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: payment_receipts
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: payment_receipts
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: payment_receipts
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- Name: bank_payment_lines bank_payment_lines_bank_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.bank_payment_lines
    ADD CONSTRAINT bank_payment_lines_bank_id_foreign FOREIGN KEY (bank_id) REFERENCES public.banks(id) ON DELETE SET NULL;


--
-- Name: bank_payment_lines bank_payment_lines_branch_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.bank_payment_lines
    ADD CONSTRAINT bank_payment_lines_branch_id_foreign FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: bank_payment_lines bank_payment_lines_payment_batch_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.bank_payment_lines
    ADD CONSTRAINT bank_payment_lines_payment_batch_id_foreign FOREIGN KEY (payment_batch_id) REFERENCES public.payment_batches(id) ON DELETE CASCADE;


--
-- Name: bank_payment_lines bank_payment_lines_payment_receipt_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.bank_payment_lines
    ADD CONSTRAINT bank_payment_lines_payment_receipt_id_foreign FOREIGN KEY (payment_receipt_id) REFERENCES public.payment_receipts(id) ON DELETE SET NULL;


--
-- Name: bank_payment_lines bank_payment_lines_third_party_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.bank_payment_lines
    ADD CONSTRAINT bank_payment_lines_third_party_id_foreign FOREIGN KEY (third_party_id) REFERENCES public.third_parties(id) ON DELETE SET NULL;


--
-- Name: import_errors import_errors_payment_batch_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.import_errors
    ADD CONSTRAINT import_errors_payment_batch_id_foreign FOREIGN KEY (payment_batch_id) REFERENCES public.payment_batches(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_branch_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_branch_id_foreign FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: invoices invoices_payment_batch_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_payment_batch_id_foreign FOREIGN KEY (payment_batch_id) REFERENCES public.payment_batches(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_payment_receipt_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_payment_receipt_id_foreign FOREIGN KEY (payment_receipt_id) REFERENCES public.payment_receipts(id) ON DELETE SET NULL;


--
-- Name: invoices invoices_third_party_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_third_party_id_foreign FOREIGN KEY (third_party_id) REFERENCES public.third_parties(id) ON DELETE SET NULL;


--
-- Name: payment_receipts payment_receipts_branch_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.payment_receipts
    ADD CONSTRAINT payment_receipts_branch_id_foreign FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: payment_receipts payment_receipts_payment_batch_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.payment_receipts
    ADD CONSTRAINT payment_receipts_payment_batch_id_foreign FOREIGN KEY (payment_batch_id) REFERENCES public.payment_batches(id) ON DELETE CASCADE;


--
-- Name: payment_receipts payment_receipts_third_party_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.payment_receipts
    ADD CONSTRAINT payment_receipts_third_party_id_foreign FOREIGN KEY (third_party_id) REFERENCES public.third_parties(id) ON DELETE SET NULL;


--
-- Name: third_party_bank_accounts third_party_bank_accounts_bank_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.third_party_bank_accounts
    ADD CONSTRAINT third_party_bank_accounts_bank_id_foreign FOREIGN KEY (bank_id) REFERENCES public.banks(id);


--
-- Name: third_party_bank_accounts third_party_bank_accounts_third_party_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: payment_receipts
--

ALTER TABLE ONLY public.third_party_bank_accounts
    ADD CONSTRAINT third_party_bank_accounts_third_party_id_foreign FOREIGN KEY (third_party_id) REFERENCES public.third_parties(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: payment_receipts
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict whVAwnAeseSgu8Cz0B2tSaeduLHeAmsxXRinbhaOC1j5Zg1yJXKz72khB87ZzSQ

