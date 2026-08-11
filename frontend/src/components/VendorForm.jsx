import { useState } from "react";

export default function VendorForm({ onSubmit }) {
  const [form, setForm] = useState({
    name: "",
    email: "",
    phone: "",
    address: "",
  });
  const [errors, setErrors] = useState({});

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const validate = () => {
    const newErrors = {};
    if (!form.name.trim()) newErrors.name = "Vendor name is required";
    if (!form.email.trim()) {
      newErrors.email = "Email is required";
    } else if (!/^\S+@\S+\.\S+$/.test(form.email)) {
      newErrors.email = "Enter a valid email";
    }
    if (!form.phone.trim()) newErrors.phone = "Phone number is required";
    if (!form.address.trim()) newErrors.address = "Address is required";
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
    onSubmit ? onSubmit(form) : console.log("Vendor submitted:", form);
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="bg-black rounded-lg shadow p-6 space-y-4 max-w-md"
    >
      <h3 className="text-lg font-semibold text-gray-800">New Vendor Record</h3>

      <div>
        <label
          htmlFor="name"
          className="block text-sm font-medium text-gray-600"
        >
          Vendor Name
        </label>
        <input
          id="name"
          name="name"
          value={form.name}
          onChange={handleChange}
          className="mt-1 w-full border rounded px-3 py-2 text-sm"
        />
        {errors.name && (
          <p className="text-red-500 text-xs mt-1">{errors.name}</p>
        )}
      </div>

      <div>
        <label
          htmlFor="email"
          className="block text-sm font-medium text-gray-600"
        >
          Email
        </label>
        <input
          id="email"
          name="email"
          value={form.email}
          onChange={handleChange}
          className="mt-1 w-full border rounded px-3 py-2 text-sm"
        />
        {errors.email && (
          <p className="text-red-500 text-xs mt-1">{errors.email}</p>
        )}
      </div>

      <div>
        <label
          htmlFor="phone"
          className="block text-sm font-medium text-gray-600"
        >
          Phone
        </label>
        <input
          id="phone"
          name="phone"
          value={form.phone}
          onChange={handleChange}
          className="mt-1 w-full border rounded px-3 py-2 text-sm"
        />
        {errors.phone && (
          <p className="text-red-500 text-xs mt-1">{errors.phone}</p>
        )}
      </div>

      <div>
        <label
          htmlFor="address"
          className="block text-sm font-medium text-gray-600"
        >
          Address
        </label>
        <input
          id="address"
          name="address"
          value={form.address}
          onChange={handleChange}
          className="mt-1 w-full border rounded px-3 py-2 text-sm"
        />
        {errors.address && (
          <p className="text-red-500 text-xs mt-1">{errors.address}</p>
        )}
      </div>

      <button
        type="submit"
        className="bg-blue-600 text-white px-4 py-2 rounded text-sm font-medium hover:bg-blue-700"
      >
        Add Vendor
      </button>
    </form>
  );
}
