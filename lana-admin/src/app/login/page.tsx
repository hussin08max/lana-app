"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Cookies from "js-cookie";
import { useForm } from "react-hook-form";
import { Phone, ShieldCheck, KeyRound } from "lucide-react";
import type { AxiosError } from "axios";

import { axiosClient } from "../../lib/axios";

type LoginFormValues = {
  phone: string;
  otp: string;
};

export default function LoginPage() {
  const router = useRouter();
  const [otpSent, setOtpSent] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    watch,
    formState: { errors },
  } = useForm<LoginFormValues>({
    defaultValues: { phone: "", otp: "" },
  });

  const phoneValue = watch("phone");

  const sendOtp = async (values: LoginFormValues) => {
    setError(null);
    setLoading(true);
    try {
      await axiosClient.post("/auth/send-otp", {
        phone: values.phone,
      });
      setOtpSent(true);
    } catch (e: unknown) {
      const err = e as AxiosError<{ message?: string }>;
      setError(err.response?.data?.message ?? "حدث خطأ أثناء إرسال OTP");
    } finally {
      setLoading(false);
    }
  };

  const verifyOtp = async (values: LoginFormValues) => {
    setError(null);
    setLoading(true);
    try {
      const res = await axiosClient.post("/auth/verify-otp", {
        phone: values.phone,
        otp: values.otp,
      });

      const token = res?.data?.accessToken as string | undefined;
      if (!token) throw new Error("Missing accessToken");

      Cookies.set("admin_token", token, {
        expires: 7,
        sameSite: "lax",
        secure: window.location.protocol === "https:",
      });

      const meRes = await axiosClient.get("/auth/me");
      const me = meRes.data;

      if (me?.role !== "ADMIN") {
        Cookies.remove("admin_token");
        throw new Error("غير مسموح لك بالدخول كمسؤول");
      }

      router.replace("/dashboard");
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : "حدث خطأ أثناء التحقق من OTP";
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-zinc-50 flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-6">
          <div className="mx-auto h-16 w-16 rounded-2xl bg-teal-500/10 flex items-center justify-center">
            <ShieldCheck className="h-8 w-8 text-teal-600" />
          </div>
          <h1 className="mt-3 text-2xl font-bold text-zinc-900">لنا</h1>
          <p className="mt-1 text-zinc-600">تسجيل دخول المسؤول</p>
        </div>

        <div className="bg-white border border-zinc-200 rounded-2xl p-6 shadow-sm">
          <form className="space-y-4" onSubmit={handleSubmit(sendOtp)}>
            <label className="block">
              <span className="text-sm font-medium text-zinc-700">
                رقم الهاتف
              </span>
              <div className="mt-1 relative">
                <Phone className="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-400 h-5 w-5" />
                <input
                  dir="ltr"
                  className="w-full rounded-xl border border-zinc-300 px-10 py-2.5 text-zinc-900 focus:outline-none focus:ring-2 focus:ring-teal-500"
                  placeholder="مثال: ٠٩٩١٢٣٤٥٦٧"
                  {...register("phone", {
                    required: "رقم الهاتف مطلوب",
                  })}
                  disabled={loading || otpSent}
                />
              </div>
              {errors.phone && (
                <p className="text-sm text-red-600 mt-2">{errors.phone.message}</p>
              )}
            </label>

            {otpSent && (
              <label className="block">
                <span className="text-sm font-medium text-zinc-700">
                  رمز التحقق
                </span>
                <div className="mt-1 relative">
                  <KeyRound className="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-400 h-5 w-5" />
                  <input
                    dir="ltr"
                    className="w-full rounded-xl border border-zinc-300 px-10 py-2.5 text-zinc-900 focus:outline-none focus:ring-2 focus:ring-teal-500"
                    placeholder="أدخل الرمز (1234 في الـ Mock)"
                    {...register("otp", { required: "رمز التحقق مطلوب" })}
                    disabled={loading}
                  />
                </div>
                {errors.otp && (
                  <p className="text-sm text-red-600 mt-2">{errors.otp.message}</p>
                )}
              </label>
            )}

            {error && (
              <div className="bg-red-50 border border-red-200 text-red-700 rounded-xl px-3 py-2 text-sm">
                {error}
              </div>
            )}

            {!otpSent ? (
              <button
                type="submit"
                disabled={loading}
                className="w-full rounded-xl bg-teal-600 text-white font-semibold py-2.5 disabled:opacity-60"
              >
                {loading ? "جاري الإرسال..." : "إرسال OTP"}
              </button>
            ) : (
              <button
                type="button"
                disabled={loading || !phoneValue}
                onClick={handleSubmit(verifyOtp)}
                className="w-full rounded-xl bg-teal-600 text-white font-semibold py-2.5 disabled:opacity-60"
              >
                {loading ? "جاري التحقق..." : "تسجيل الدخول"}
              </button>
            )}
          </form>
        </div>
      </div>
    </div>
  );
}

