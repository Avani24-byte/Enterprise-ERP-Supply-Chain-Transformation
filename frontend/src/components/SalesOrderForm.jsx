import { useState } from "react";

export default function SalesOrderForm({ onSubmit }) {
  const [form, setForm] = useState({
    customer: "",
    item: "",
    quantity: "",
    deliveryDate: "",
  });
  const [errors, setErrors] = useState({});

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const validate = () => {
    const newErrors = {};
    if (!form.customer.trim()) newErrors.customer = "Customer is required";
    if (!form.item.trim()) newErrors.item = "Item is required";
    if (!form.quantity || Number(form.quantity) <= 0)
      newErrors.quantity = "Quantity must be greater than 0";
    if (!form.deliveryDate)
      newErrors.deliveryDate = "Delivery date is required";
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
    onSubmit ? onSubmit(form) : console.log("Sales order submitted:", form);
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="bg-white rounded-lg shadow p-6 space-y-4 max-w-md"
    >
      <h3 className="text-lg font-semibold text-gray-800">New Sales Order</h3>

      <div>
        <label
          htmlFor="customer"
          className="block text-sm font-medium text-gray-600"
        >
          Customer
        </label>
        <input
          id="customer"
          name="customer"
          value={form.customer}
          onChange={handleChange}
          className="mt-1 w-full border rounded px-3 py-2 text-sm"
        />
        {errors.customer && (
          <p className="text-red-500 text-xs mt-1">{errors.customer}</p>
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
          htmlFor="deliveryDate"
          className="block text-sm font-medium text-gray-600"
        >
          Delivery Date
        </label>
        <input
          id="deliveryDate"
          type="date"
          name="deliveryDate"
          value={form.deliveryDate}
          onChange={handleChange}
          className="mt-1 w-full border rounded px-3 py-2 text-sm"
        />
        {errors.deliveryDate && (
          <p className="text-red-500 text-xs mt-1">{errors.deliveryDate}</p>
        )}
      </div>

      <button
        type="submit"
        className="bg-blue-600 text-white px-4 py-2 rounded text-sm font-medium hover:bg-blue-700"
      >
        Create Sales Order
      </button>
    </form>
  );
}
