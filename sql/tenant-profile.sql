-- ============================================================
-- Tenant & Pembayaran: perluasan data penghuni + tabel relasi
-- Jalankan sekali di Supabase SQL Editor project ini.
-- ============================================================

ALTER TABLE public.tenants
  ADD COLUMN IF NOT EXISTS nik text,
  ADD COLUMN IF NOT EXISTS student_card text,
  ADD COLUMN IF NOT EXISTS home_address text,
  ADD COLUMN IF NOT EXISTS current_address text,
  ADD COLUMN IF NOT EXISTS email text,
  ADD COLUMN IF NOT EXISTS school_work_address text,
  ADD COLUMN IF NOT EXISTS maps_home_url text,
  ADD COLUMN IF NOT EXISTS maps_school_url text,
  ADD COLUMN IF NOT EXISTS documents jsonb NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS rules_agreed boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS rules_agreed_at timestamptz,
  ADD COLUMN IF NOT EXISTS room_id uuid REFERENCES public.rooms(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS check_in_date date,
  ADD COLUMN IF NOT EXISTS rent_period text,
  ADD COLUMN IF NOT EXISTS due_date date;

UPDATE public.tenants SET status = 'Tidak Aktif' WHERE status = 'Nonaktif';

CREATE INDEX IF NOT EXISTS tenants_room_id_idx ON public.tenants(room_id);
CREATE INDEX IF NOT EXISTS tenants_status_idx ON public.tenants(status);

-- ---------- nomor telepon (bisa lebih dari satu) ----------
CREATE TABLE IF NOT EXISTS public.tenant_phones (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  phone text NOT NULL,
  label text,
  is_primary boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS tenant_phones_tenant_id_idx ON public.tenant_phones(tenant_id);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.tenant_phones TO anon, authenticated;
GRANT ALL ON public.tenant_phones TO service_role;
ALTER TABLE public.tenant_phones ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public full access to tenant_phones" ON public.tenant_phones;
CREATE POLICY "Public full access to tenant_phones" ON public.tenant_phones
  FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- ---------- kontak darurat ----------
CREATE TABLE IF NOT EXISTS public.tenant_emergency_contacts (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  name text NOT NULL,
  relationship text,
  phone text NOT NULL,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS tenant_emergency_contacts_tenant_id_idx
  ON public.tenant_emergency_contacts(tenant_id);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.tenant_emergency_contacts TO anon, authenticated;
GRANT ALL ON public.tenant_emergency_contacts TO service_role;
ALTER TABLE public.tenant_emergency_contacts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public full access to tenant_emergency_contacts"
  ON public.tenant_emergency_contacts;
CREATE POLICY "Public full access to tenant_emergency_contacts" ON public.tenant_emergency_contacts
  FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- ---------- kendaraan ----------
CREATE TABLE IF NOT EXISTS public.tenant_vehicles (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  vehicle_type text NOT NULL,
  brand_model text,
  plate_number text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS tenant_vehicles_tenant_id_idx ON public.tenant_vehicles(tenant_id);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.tenant_vehicles TO anon, authenticated;
GRANT ALL ON public.tenant_vehicles TO service_role;
ALTER TABLE public.tenant_vehicles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public full access to tenant_vehicles" ON public.tenant_vehicles;
CREATE POLICY "Public full access to tenant_vehicles" ON public.tenant_vehicles
  FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- ---------- riwayat pembayaran tenant ----------
CREATE TABLE IF NOT EXISTS public.tenant_payments (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  payment_date date NOT NULL DEFAULT CURRENT_DATE,
  period_type text NOT NULL DEFAULT '1 Bulan',
  period_start date,
  period_end date,
  amount numeric NOT NULL DEFAULT 0,
  payment_method text NOT NULL DEFAULT 'Transfer Bank',
  notes text,
  attachments jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS tenant_payments_tenant_id_idx ON public.tenant_payments(tenant_id);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.tenant_payments TO anon, authenticated;
GRANT ALL ON public.tenant_payments TO service_role;
ALTER TABLE public.tenant_payments ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public full access to tenant_payments" ON public.tenant_payments;
CREATE POLICY "Public full access to tenant_payments" ON public.tenant_payments
  FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
DROP TRIGGER IF EXISTS tenant_payments_updated_at ON public.tenant_payments;
CREATE TRIGGER tenant_payments_updated_at BEFORE UPDATE ON public.tenant_payments
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ---------- riwayat status tenant ----------
CREATE TABLE IF NOT EXISTS public.tenant_status_history (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  old_status text,
  new_status text NOT NULL,
  notes text,
  changed_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS tenant_status_history_tenant_id_idx
  ON public.tenant_status_history(tenant_id);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.tenant_status_history TO anon, authenticated;
GRANT ALL ON public.tenant_status_history TO service_role;
ALTER TABLE public.tenant_status_history ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public full access to tenant_status_history" ON public.tenant_status_history;
CREATE POLICY "Public full access to tenant_status_history" ON public.tenant_status_history
  FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- ---------- trigger pencatat riwayat status ----------
CREATE OR REPLACE FUNCTION public.log_tenant_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.tenant_status_history (tenant_id, old_status, new_status)
    VALUES (NEW.id, NULL, NEW.status);
  ELSIF NEW.status IS DISTINCT FROM OLD.status THEN
    INSERT INTO public.tenant_status_history (tenant_id, old_status, new_status)
    VALUES (NEW.id, OLD.status, NEW.status);
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tenants_status_history ON public.tenants;
CREATE TRIGGER tenants_status_history
  AFTER INSERT OR UPDATE OF status ON public.tenants
  FOR EACH ROW EXECUTE FUNCTION public.log_tenant_status_change();
