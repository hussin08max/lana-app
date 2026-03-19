"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import type { AxiosError } from "axios";
import { axiosClient } from "../../../../lib/axios";
import Link from "next/link";

type CreateCaseValues = {
  title: string;
  description: string;
  location: string;
  priority: number;
};

export default function CreateCasePage() {
  const router = useRouter();
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<CreateCaseValues>({
    defaultValues: {
      title: "",
      description: "",
      location: "",
      priority: 0,
    },
  });

  const onSubmit = async (values: CreateCaseValues) => {
    setSubmitting(true);
    setError(null);
    try {
      await axiosClient.post("/cases", {
        title: values.title,
        description: values.description,
        location: values.location,
        priority: values.priority,
      });

      router.push("/dashboard");
    } catch (e: unknown) {
      const err = e as AxiosError<{ message?: string }>;
      setError(err.response?.data?.message ?? "تعذر إنشاء الحالة");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-3">
        <div>
          <h2 className="text-xl font-semibold text-gray-900">إنشاء حالة جديدة</h2>
          <p className="text-sm text-gray-600">أدخل تفاصيل الحالة لتظهر للمستفيدين والمتبرعين.</p>
        </div>

        <Link
          href="/dashboard"
          className="inline-flex items-center rounded-xl border border-gray-200 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
        >
          رجوع إلى لوحة التحكم
        </Link>
      </div>

      <div className="bg-white border border-gray-200 rounded-2xl p-6">
        {error && (
          <div className="mb-4 bg-red-50 border border-red-200 text-red-700 rounded-xl p-4 text-sm">
            {error}
          </div>
        )}

        <form className="space-y-4" onSubmit={handleSubmit(onSubmit)}>
          <div>
            <label className="block text-sm font-medium text-gray-700">
              العنوان
            </label>
            <input
              className="mt-1 w-full rounded-xl border border-gray-300 px-3 py-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-teal-500"
              placeholder="مثال: علاج طبي عاجل"
              {...register("title", { required: "العنوان مطلوب" })}
            />
            {errors.title && (
              <p className="mt-2 text-sm text-red-600">{errors.title.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              الوصف
            </label>
            <textarea
              className="mt-1 w-full min-h-[110px] rounded-xl border border-gray-300 px-3 py-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-teal-500"
              placeholder="اكتب تفاصيل الحالة..."
              {...register("description", {
                required: "الوصف مطلوب",
              })}
            />
            {errors.description && (
              <p className="mt-2 text-sm text-red-600">
                {errors.description.message}
              </p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              الموقع
            </label>
            <input
              className="mt-1 w-full rounded-xl border border-gray-300 px-3 py-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-teal-500"
              placeholder="مثال: أم درمان - ولاية الخرطوم"
              {...register("location", { required: "الموقع مطلوب" })}
            />
            {errors.location && (
              <p className="mt-2 text-sm text-red-600">
                {errors.location.message}
              </p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">
              الأولوية (0 - 10)
            </label>
            <input
              type="number"
              min={0}
              max={10}
              className="mt-1 w-full rounded-xl border border-gray-300 px-3 py-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-teal-500"
              {...register("priority", {
                required: "الأولوية مطلوبة",
                valueAsNumber: true,
                min: { value: 0, message: "الأولوية لا يمكن أن تكون أقل من 0" },
                max: { value: 10, message: "الأولوية لا يمكن أن تكون أكثر من 10" },
              })}
            />
            {errors.priority && (
              <p className="mt-2 text-sm text-red-600">
                {errors.priority.message}
              </p>
            )}
          </div>

          <div className="pt-2 flex items-center justify-end">
            <button
              type="submit"
              disabled={submitting}
              className="inline-flex items-center gap-2 rounded-xl bg-teal-600 text-white px-5 py-2 text-sm font-semibold hover:bg-teal-700 disabled:opacity-60"
            >
              {submitting ? "جاري الإنشاء..." : "إنشاء الحالة"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

