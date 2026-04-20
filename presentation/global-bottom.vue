<template>
  <footer class="absolute bottom-2 left-0 right-0 flex items-center justify-between px-4 text-xs opacity-60">
    <span>
      <img src="https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg" class="inline h-3 mr-1 brightness-0 invert" alt="AWS" />
      © 2026, Amazon Web Services, Inc. or its affiliates. All rights reserved. Amazon Confidential and Trademark.
    </span>
    <span>{{ $slidev.nav.currentPage }} / {{ $slidev.nav.total }}</span>
  </footer>
</template>
