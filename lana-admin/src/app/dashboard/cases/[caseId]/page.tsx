"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import type { AxiosError } from "axios";
import { axiosClient } from "../../../../lib/axios";

type Params = {
  params: {
    caseId: string;
  };
};

type CreatedByUser = { id: string; name: string };
type CaseDetails = {
  id: string;
  title: string;
  description: string;
  location: string;
  status: string;
  priority: number;
  createdByUser?: CreatedByUser;
};

type DonationRow = {
  id: string;
  amount: string | number;
  status: string;
  createdAt: string;
};

function formatDate(d: string) {
  const dt = new Date(d);
  if (Number.isNaN(dt.getTime())) return d;
  return dt.toLocaleString("ar", {
    year: "numeric",
    month: "short",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export default function CaseDetailsDonationsPage({ params }: Params) {
  const caseId = params.caseId;

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [caseDetails, setCaseDetails] = useState<CaseDetails | null>(null);
  const [donations, setDonations] = useState<DonationRow[]>([]);

  useEffect(() => {
    (async () => {
      setLoading(true);
      setError(null);

      try {
        const [caseRes, donationsRes] = await Promise.all([
          axiosClient.get<CaseDetails>(`/cases/${caseId}`),
          axiosClient.get<DonationRow[]>(`/donations/case/${caseId}`),
        ]);

        setCaseDetails(caseRes.data);
        setDonations(donationsRes.data ?? []);
      } catch (e: unknown) {
        const err = e as AxiosError<{ message?: string }>;
        setError(err.response?.data?.message ?? "تعذر تحميل بيانات الحالة");
      } finally {
        setLoading(false);
      }
    })();
  }, [caseId]);

  const priorityBadge = useMemo(() => {
    if (!caseDetails) return "bg-teal-50 text-teal-700 border-teal-200";
    const p = caseDetails.priority;
    if (p >= 7) return "bg-red-50 text-red-700 border-red-200";
    if (p >= 4) return "bg-amber-50 text-amber-700 border-amber-200";
    return "bg-teal-50 text-teal-700 border-teal-200";
  }, [caseDetails]);

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h2 className="text-xl font-semibold text-gray-900">
            تفاصيل الحالة والتبرعات
          </h2>
          <p className="text-sm text-gray-600">
            رقم الحالة: <span dir="ltr">{caseId}</span>
          </p>
        </div>

        <Link
          href="/dashboard"
          className="inline-flex items-center rounded-xl border border-gray-200 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
        >
          رجوع إلى لوحة التحكم
        </Link>
      </div>

      {loading ? (
        <div className="py-10 flex items-center justify-center">
          <div className="h-10 w-10 border-2 border-teal-200 border-t-teal-600 rounded-full animate-spin" />
        </div>
      ) : error ? (
        <div className="bg-red-50 border border-red-200 text-red-700 rounded-xl p-4 text-sm">
          {error}
        </div>
      ) : (
        <>
          <div className="bg-white border border-gray-200 rounded-2xl p-6">
            <div className="flex items-start justify-between gap-4">
              <div className="space-y-2">
                <h3 className="text-lg font-semibold text-gray-900">
                  {caseDetails?.title ?? "—"}
                </h3>
                <p className="text-sm text-gray-600">{caseDetails?.description}</p>
              </div>
              <div className="flex flex-col items-end gap-2">
                <span
                  className={[
                    "inline-flex items-center rounded-full border px-3 py-1 text-xs font-semibold",
                    priorityBadge,
                  ].join(" ")}
                >
                  أولوية {caseDetails?.priority ?? 0}
                </span>
                <span className="inline-flex items-center rounded-full bg-gray-100 text-gray-700 border border-gray-200 px-3 py-1 text-xs font-semibold">
                  {caseDetails?.status ?? "—"}
                </span>
              </div>
            </div>

            <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <div className="text-xs uppercase tracking-wide text-gray-500">
                  الموقع
                </div>
                <div className="text-sm font-medium text-gray-900">
                  {caseDetails?.location ?? "—"}
                </div>
              </div>
              <div>
                <div className="text-xs uppercase tracking-wide text-gray-500">
                  أضيف بواسطة
                </div>
                <div className="text-sm font-medium text-gray-900">
                  {caseDetails?.createdByUser?.name ?? "—"}
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white border border-gray-200 rounded-2xl p-6 overflow-hidden">
            <div className="flex items-start justify-between gap-3 mb-4">
              <div>
                <h3 className="text-lg font-semibold text-gray-900">
                  جدول التبرعات
                </h3>
                <p className="text-sm text-gray-600">
                  عرض جميع التبرعات الخاصة بهذه الحالة
                </p>
              </div>
            </div>

            <div className="overflow-x-auto">
              <table className="min-w-full text-sm">
                <thead className="bg-gray-50 text-gray-600">
                  <tr>
                    <th className="py-3 px-4 text-right font-semibold">Donation ID</th>
                    <th className="py-3 px-4 text-right font-semibold">المبلغ</th>
                    <th className="py-3 px-4 text-right font-semibold">الحالة</th>
                    <th className="py-3 px-4 text-right font-semibold">التاريخ</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {donations.map((d) => (
                    <tr key={d.id} className="hover:bg-gray-50/50">
                      <td className="py-3 px-4 text-gray-800" dir="ltr">
                        {d.id}
                      </td>
                      <td className="py-3 px-4 text-gray-800 font-medium">
                        {d.amount} جنيه سوداني
                      </td>
                      <td className="py-3 px-4 text-gray-700">{d.status}</td>
                      <td className="py-3 px-4 text-gray-700">
                        {formatDate(d.createdAt)}
                      </td>
                    </tr>
                  ))}
                  {donations.length === 0 && (
                    <tr>
                      <td colSpan={4} className="py-10 px-4 text-center text-gray-500">
                        لا توجد تبرعات لهذه الحالة حالياً
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

