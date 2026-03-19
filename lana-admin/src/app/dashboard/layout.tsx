"use client";

import { ReactNode, useEffect, useMemo, useState } from "react";
import Cookies from "js-cookie";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  LayoutDashboard,
  ClipboardList,
  Users,
  Settings,
  LogOut,
} from "lucide-react";

import { axiosClient } from "../../lib/axios";

type MeResponse = {
  name?: string;
  role?: string;
};

function NavItem({
  href,
  label,
  active,
  icon,
}: {
  href: string;
  label: string;
  active: boolean;
  icon: ReactNode;
}) {
  return (
    <Link
      href={href}
      className={[
        "flex items-center gap-3 rounded-xl px-4 py-3 text-sm transition-colors",
        active
          ? "bg-teal-50 text-teal-700 font-semibold"
          : "text-gray-600 hover:bg-gray-50 hover:text-gray-900",
      ].join(" ")}
    >
      <span className={active ? "text-teal-600" : "text-gray-400"}>{icon}</span>
      {label}
    </Link>
  );
}

export default function DashboardLayout({ children }: { children: ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();

  const [loading, setLoading] = useState(true);
  const [adminName, setAdminName] = useState<string>("—");

  const activeKey = useMemo(() => {
    // نحدد الحالة النشطة بناءً على المسار
    if (!pathname) return "dashboard";
    if (pathname.startsWith("/dashboard/cases")) return "cases";
    if (pathname.startsWith("/dashboard/agents")) return "agents";
    if (pathname.startsWith("/dashboard/settings")) return "settings";
    return "dashboard";
  }, [pathname]);

  useEffect(() => {
    const token = Cookies.get("admin_token");
    if (!token) {
      router.replace("/login");
      return;
    }

      (async () => {
        try {
          const res = await axiosClient.get<MeResponse>("/auth/me");
          const me = res.data;

          if (me?.role !== "ADMIN") {
            Cookies.remove("admin_token");
            router.replace("/login");
            return;
          }

          setAdminName(me?.name ?? "—");
        } catch {
          Cookies.remove("admin_token");
          router.replace("/login");
        } finally {
          setLoading(false);
        }
      })();
  }, [router]);

  const logout = () => {
    Cookies.remove("admin_token");
    router.replace("/login");
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-gray-600">جاري التحقق...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 rtl">
      <div className="flex min-h-screen">
        <aside className="hidden md:flex w-64 bg-white border-r border-gray-200">
          <div className="p-6">
            <div className="text-lg font-bold text-gray-900">لانا</div>
            <div className="text-xs text-gray-500 mt-1">
              لوحة الإدارة
            </div>
          </div>

          <nav className="flex flex-col gap-1 p-2">
            <NavItem
              href="/dashboard"
              label="لوحة التحكم"
              active={activeKey === "dashboard"}
              icon={<LayoutDashboard size={18} />}
            />
            <NavItem
              href="/dashboard/cases"
              label="الحالات"
              active={activeKey === "cases"}
              icon={<ClipboardList size={18} />}
            />
            <NavItem
              href="/dashboard/agents"
              label="الوكلاء"
              active={activeKey === "agents"}
              icon={<Users size={18} />}
            />
            <NavItem
              href="/dashboard/settings"
              label="الإعدادات"
              active={activeKey === "settings"}
              icon={<Settings size={18} />}
            />
          </nav>
        </aside>

        <div className="flex-1 flex flex-col">
          <header className="h-16 bg-white border-b border-gray-200 px-6 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="text-sm text-gray-600">مرحباً،</div>
              <div className="text-sm font-semibold text-gray-900">
                {adminName}
              </div>
            </div>
            <button
              type="button"
              onClick={logout}
              className="inline-flex items-center gap-2 rounded-xl border border-gray-200 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
            >
              <LogOut size={16} />
              خروج
            </button>
          </header>

          <main className="flex-1 p-6">{children}</main>
        </div>
      </div>
    </div>
  );
}

