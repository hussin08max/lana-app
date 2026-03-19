"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import type { AxiosError } from "axios";
import { Plus, Eye } from "lucide-react";

import { axiosClient } from "../../lib/axios";

type CreatedByUser = { id: string; name: string };
type CaseItem = {
  id: string;
  title: string;
  location: string;
  priority: number;
  status: string;
  createdByUser?: CreatedByUser;
};

export default function DashboardPage() {
  const router = useRouter();
  const [cases, setCases] = useState<CaseItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        setError(null);
        const res = await axiosClient.get<CaseItem[]>("/cases");
        setCases(res.data ?? []);
      } catch (e: unknown) {
        const err = e as AxiosError<{ message?: string }>;
        setError(err.response?.data?.message ?? "تعذر تحميل الحالات");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const priorityBadge = (p: number) => {
    if (p >= 7) return "bg-red-50 text-red-700 border-red-200";
    if (p >= 4) return "bg-amber-50 text-amber-700 border-amber-200";
    return "bg-teal-50 text-teal-700 border-teal-200";
  };

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h2 className="text-xl font-semibold text-gray-900">
            إدارة الحالات
          </h2>
          <p className="text-sm text-gray-600">
            نظرة عامة على الحالات المفتوحة حالياً
          </p>
        </div>

        <button
          type="button"
          onClick={() => alert("قريباً: إضافة حالة جديدة")}
          className="inline-flex items-center gap-2 rounded-xl bg-teal-600 text-white px-4 py-2 text-sm font-semibold hover:bg-teal-700"
        >
          <Plus size={16} />
          إنشاء حالة جديدة
        </button>
      </div>

      {loading ? (
        <div className="py-10 flex items-center justify-center">
          <div className="h-10 w-10 border-2 border-teal-200 border-t-teal-600 rounded-full animate-spin" />
        </div>
      ) : error ? (
        <div className="bg-red-50 border border-red-200 text-red-700 rounded-xl p-4">
          {error}
        </div>
      ) : (
        <div className="bg-white border border-gray-200 rounded-2xl overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full text-sm">
              <thead className="bg-gray-50 text-gray-600">
                <tr>
                  <th className="py-3 px-4 text-right font-semibold">ID</th>
                  <th className="py-3 px-4 text-right font-semibold">العنوان</th>
                  <th className="py-3 px-4 text-right font-semibold">الموقع</th>
                  <th className="py-3 px-4 text-right font-semibold">الأولوية</th>
                  <th className="py-3 px-4 text-right font-semibold">الحالة</th>
                  <th className="py-3 px-4 text-right font-semibold">
                    الإجراءات
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {cases.map((c) => (
                  <tr key={c.id} className="hover:bg-gray-50/50">
                    <td className="py-3 px-4 text-gray-800">{c.id}</td>
                    <td className="py-3 px-4 text-gray-800 font-medium">
                      {c.title}
                    </td>
                    <td className="py-3 px-4 text-gray-700">{c.location}</td>
                    <td className="py-3 px-4">
                      <span
                        className={[
                          "inline-flex items-center rounded-full border px-3 py-1 text-xs font-semibold",
                          priorityBadge(c.priority),
                        ].join(" ")}
                      >
                        {c.priority}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-gray-700">
                      {c.status}
                    </td>
                    <td className="py-3 px-4">
                      <div className="flex items-center gap-2 justify-end">
                        <button
                          type="button"
                          onClick={() =>
                            router.push(`/dashboard/cases/${c.id}`)
                          }
                          className="inline-flex items-center gap-2 rounded-xl border border-teal-200 bg-teal-50 text-teal-800 px-3 py-2 text-xs font-semibold hover:bg-teal-100"
                        >
                          <Eye size={14} />
                          عرض التبرعات
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
                {cases.length === 0 && (
                  <tr>
                    <td colSpan={6} className="py-10 px-4 text-center text-gray-500">
                      لا توجد حالات حالياً
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}

