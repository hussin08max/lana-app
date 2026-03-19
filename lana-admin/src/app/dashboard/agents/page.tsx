"use client";

import { useEffect, useMemo, useState } from "react";
import type { AxiosError } from "axios";
import { axiosClient } from "../../lib/axios";
import { Loader2 } from "lucide-react";

const USER_ROLE_OPTIONS = ["ADMIN", "AGENT", "DONOR", "NEEDY"] as const;
type UserRole = (typeof USER_ROLE_OPTIONS)[number];

type UserItem = {
  id: string;
  name: string;
  phone: string;
  role: UserRole;
  verified: boolean;
  createdAt: string;
};

function formatDate(d: string) {
  const dt = new Date(d);
  if (Number.isNaN(dt.getTime())) return d;
  return dt.toLocaleDateString("ar", {
    year: "numeric",
    month: "short",
    day: "2-digit",
  });
}

function roleBadgeStyles(role: UserRole) {
  switch (role) {
    case "ADMIN":
      return "bg-purple-50 text-purple-700 border-purple-200";
    case "AGENT":
      return "bg-blue-50 text-blue-700 border-blue-200";
    case "DONOR":
      return "bg-gray-100 text-gray-700 border-gray-200";
    case "NEEDY":
      return "bg-amber-50 text-amber-800 border-amber-200";
    default:
      return "bg-gray-100 text-gray-700 border-gray-200";
  }
}

function verifiedBadgeStyles(verified: boolean) {
  return verified
    ? "bg-teal-50 text-teal-700 border-teal-200"
    : "bg-gray-100 text-gray-700 border-gray-200";
}

export default function AgentsPage() {
  const [users, setUsers] = useState<UserItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [updatingUserId, setUpdatingUserId] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [messageType, setMessageType] = useState<"success" | "error">("success");

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        setError(null);

        const res = await axiosClient.get<UserItem[]>("/users");
        setUsers(res.data ?? []);
      } catch (e: unknown) {
        const err = e as AxiosError<{ message?: string }>;
        setError(err.response?.data?.message ?? "تعذر تحميل المستخدمين");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const roleOptions = useMemo(() => {
    return USER_ROLE_OPTIONS.map((r) => ({
      value: r,
      label:
        r === "ADMIN"
          ? "ADMIN (مسؤول)"
          : r === "AGENT"
            ? "AGENT (وكيل)"
            : r === "DONOR"
              ? "DONOR (متبرع)"
              : "NEEDY (مستفيد)",
    }));
  }, []);

  const updateRole = async (userId: string, newRole: UserRole) => {
    setMessage(null);
    setUpdatingUserId(userId);

    try {
      const res = await axiosClient.patch<UserItem>(`/users/${userId}/role`, {
        role: newRole,
      });

      const updated = res.data;
      setUsers((prev) => prev.map((u) => (u.id === userId ? updated : u)));

      setMessage("تم تحديث الدور بنجاح");
      setMessageType("success");
    } catch (e: unknown) {
      const err = e as AxiosError<{ message?: string }>;
      setMessage(err.response?.data?.message ?? "تعذر تحديث الدور");
      setMessageType("error");
    } finally {
      setUpdatingUserId(null);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h2 className="text-xl font-semibold text-gray-900">إدارة الوكلاء والمستخدمين</h2>
          <p className="text-sm text-gray-600">عرض المستخدمين وتغيير دورهم (Admin فقط).</p>
        </div>
      </div>

      {message && (
        <div
          className={[
            "rounded-xl p-4 text-sm border",
            messageType === "success"
              ? "bg-teal-50 border-teal-200 text-teal-800"
              : "bg-red-50 border-red-200 text-red-700",
          ].join(" ")}
          role="status"
          aria-live="polite"
        >
          {message}
        </div>
      )}

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
                  <th className="py-3 px-4 text-right font-semibold">الاسم</th>
                  <th className="py-3 px-4 text-right font-semibold">الهاتف</th>
                  <th className="py-3 px-4 text-right font-semibold">الحالة</th>
                  <th className="py-3 px-4 text-right font-semibold">تاريخ الانضمام</th>
                  <th className="py-3 px-4 text-right font-semibold">الدور</th>
                  <th className="py-3 px-4 text-right font-semibold">الإجراءات</th>
                </tr>
              </thead>

              <tbody className="divide-y divide-gray-100">
                {users.map((u) => {
                  const isUpdating = updatingUserId === u.id;
                  return (
                    <tr
                      key={u.id}
                      className={[
                        "hover:bg-gray-50/50",
                        isUpdating ? "opacity-70" : "",
                      ].join(" ")}
                    >
                      <td className="py-3 px-4 text-gray-800 font-medium">{u.name}</td>
                      <td className="py-3 px-4 text-gray-700" dir="ltr">{u.phone}</td>
                      <td className="py-3 px-4">
                        <span
                          className={[
                            "inline-flex items-center rounded-full border px-3 py-1 text-xs font-semibold",
                            verifiedBadgeStyles(u.verified),
                          ].join(" ")}
                        >
                          {u.verified ? "موثّق" : "غير موثّق"}
                        </span>
                      </td>
                      <td className="py-3 px-4 text-gray-700">{formatDate(u.createdAt)}</td>
                      <td className="py-3 px-4">
                        <span
                          className={[
                            "inline-flex items-center rounded-full border px-3 py-1 text-xs font-semibold",
                            roleBadgeStyles(u.role),
                          ].join(" ")}
                        >
                          {u.role}
                        </span>
                      </td>
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-3 justify-end">
                          <select
                            disabled={isUpdating}
                            value={u.role}
                            onChange={(e) => {
                              const nextRole = e.target.value as UserRole;
                              updateRole(u.id, nextRole);
                            }}
                            className="rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm text-gray-900 focus:outline-none focus:ring-2 focus:ring-teal-500 disabled:opacity-60"
                          >
                            {roleOptions.map((opt) => (
                              <option key={opt.value} value={opt.value}>
                                {opt.label}
                              </option>
                            ))}
                          </select>

                          {isUpdating && (
                            <span
                              className="inline-flex items-center justify-center text-teal-700"
                              aria-label="جارٍ التحديث"
                            >
                              <Loader2 className="h-5 w-5 animate-spin" />
                            </span>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })}

                {users.length === 0 && (
                  <tr>
                    <td colSpan={6} className="py-10 px-4 text-center text-gray-500">
                      لا يوجد مستخدمون
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


