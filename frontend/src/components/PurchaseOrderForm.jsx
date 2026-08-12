import { useState } from "react";

export default function PurchaseOrderForm({ onSubmit }) {
  const [form, setForm] = useState({
    vendor: "",
    item: "",
    quantity: "",
    expectedDate: "",
  });
  const [errors, setErrors] = useState({});

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const validate = () => {
    const newErrors = {};
    if (!form.vendor.trim()) newErrors.vendor = "Vendor is required";
    if (!form.item.trim()) newErrors.item = "Item is required";
    if (!form.quantity || Number(form.quantity) <= 0)
      newErrors.quantity = "Quantity must be greater than 0";
    if (!form.expectedDate)
      newErrors.expectedDate = "Expected date is required";
    return newErrors;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const newErrors = validate();
    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }
    setErrors({});
    onSubmit ? onSubmit(form) : console.log("PO submitted:", form);
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="bg-black rounded-lg shadow p-6 space-y-4 max-w-md"
    >
      <h3 className="text-lg font-semibold text-gray-800">
        New Purchase Order
      </h3>

      <div>
        {/* added htmlFor */}
        <label
          htmlFor="vendor"
          className="block text-sm font-medium text-gray-600"
        >
          Vendor
        </label>
        <input
          id="vendor"
          name="vendor"
          value={form.vendor}
          onChange={handleChange}
          className="mt-1 w-full border rounded px-3 py-2 text-sm"
        />
        {errors.vendor && (
          <p className="text-red-500 text-xs mt-1">{errors.vendor}</p>
        )}
      </div>

      <div>
        <label
          htmlFor="item"
          className="block text-sm font-medium text-gray-600"
        >
          Item
        </label>
        <input
          id="item"
          name="item"
          value={form.item}
          onChange={handleChange}
          className="mt-1 w-full border rounded px-3 py-2 text-sm"
        />
        {errors.item && (
          <p className="text-red-500 text-xs mt-1">{errors.item}</p>
        )}
      </div>

      <div>
        <label
          htmlFor="quantity"
          className="block text-sm font-medium text-gray-600"
        >
          Quantity
        </label>
        <input
          id="quantity"
          type="number"
          name="quantity"
          value={form.quantity}
          onChange={handleChange}
          className="mt-1 w-full border rounded px-3 py-2 text-sm"
        />
        {errors.quantity && (
          <p className="text-red-500 text-xs mt-1">{errors.quantity}</p>
        )}
      </div>

      <div>
        <label
          htmlFor="expectedDate"
          className="block text-sm font-medium text-gray-600"
        >
          Expected Date
        </label>
        <input
          id="expectedDate"
          type="date"
          name="expectedDate"
          value={form.expectedDate}
          onChange={handleChange}
          className="mt-1 w-full border rounded px-3 py-2 text-sm"
        />
        {errors.expectedDate && (
          <p className="text-red-500 text-xs mt-1">{errors.expectedDate}</p>
        )}
      </div>

      <button
        type="submit"
        className="bg-blue-600 text-white px-4 py-2 rounded text-sm font-medium hover:bg-blue-700"
      >
        Create PO
      </button>
    </form>
  );
}
