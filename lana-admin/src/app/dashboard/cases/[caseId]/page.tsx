type Params = {
  params: {
    caseId: string;
  };
};

export default function CaseDonationsPlaceholderPage({ params }: Params) {
  return (
    <div className="bg-white border border-gray-200 rounded-2xl p-6">
      <h1 className="text-lg font-semibold text-gray-900 mb-2">
        التبرعات للحالة
      </h1>
      <p className="text-sm text-gray-600">
        قريباً: صفحة تفاصيل التبرعات للحالة رقم <span dir="ltr">{params.caseId}</span>.
      </p>
    </div>
  );
}

