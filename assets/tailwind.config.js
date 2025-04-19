// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");

module.exports = {
  content: ["./js/**/*.js", "../lib/*_web.ex", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      colors: {
        Brand: {
          LG: "#16E684",
          MG: "#00C694",
          DG: "#0C6070",
          DK: "#101820",
        },
        B: {
          25: "#F4FDFA",
          50: "#ECFDF6",
          100: "#D0FBE6",
          200: "#A6F4D2",
          300: "#6CE9BB",
          400: "#29CD96",
          500: "#0DBC87",
          600: "#02996E",
          700: "#027A5C",
          800: "#04614A",
          900: "#054F3E",
        },
        N: {
          25: "#FCFCFD",
          50: "#F8FAFC",
          100: "#F1F5F9",
          200: "#E2E8F0",
          300: "#CBD5E1",
          400: "#94A3B8",
          500: "#64748B",
          600: "#475569",
          700: "#334155",
          800: "#1E293B",
          900: "#0F172A",
        },
        G: {
          25: "#FAFAFA",
          50: "#F5F5F5",
          100: "#E5E5E5",
          200: "#D4D4D4",
          300: "#A3A3A3",
          400: "#737373",
          500: "#525252",
          600: "#404040",
          700: "#262626",
          800: "#171717",
          900: "#000000",
        },
        R: {
          50: "#FEF3F2",
          200: "#FECDCA",
          400: "#F97066",
          500: "#f14e42",
          600: "#de3124",
        },
        Y: {
          25: "#FEF3F2",
          200: "#ffee85",
          400: "#ffcd1b",
          500: "#ffab00",
          600: "#e28200",
        },
      },
      fontWeight: {
        rg: "400",
        md: "500",
        smb: "600",
        bold: "700",
        extra: "800",
      },
      zIndex: {
        1: "1",
      },
      fontFamily: {
        sans: [
          '"Inter", sans-serif',
        ],
      },
      screens: {
        'smb': "468px",
        'md': '632px',
        'lg': '1024px',
        xl: { max: "1200px" },
        // => @media (max-width: 1279px) { ... }

        lg: { max: "1024px" },
        // => @media (max-width: 1023px) { ... }

        normal: { max: "600px" },
        // => @media (max-width: 767px) { ... }

        md: { max: "767px" },
        // => @media (max-width: 767px) { ... }

        sm: { max: "639px" },
        // => @media (max-width: 639px) { ... }

        smb: { max: "468px" },
        // => @media (max-width: 400px) { ... }
      },
      minWidth: {
        lg: "1200px",
        xl: "1500px",
        "2xl": "2200px",
        "3xl": "2800px",
        "4xl": "3600px",
      },
      maxWidth: {
        'smb': "468px",
        'normal': "600px",
        'md': '767px',
        'lg': '1024px'
      },
    },

  },
  safelist: [
    {
      pattern:
        /(m(t|l|r|b|x|y)-+)|(p(t|l|r|b|x|y)-+)|(w-+)/,
    },
  ],
  plugins: [
    require("@tailwindcss/forms"),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ])
    ),
  ],
};
