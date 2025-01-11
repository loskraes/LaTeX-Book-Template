\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{arsar-book}[2025/01/11 Custom template for book]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax

\LoadClass{book}

\RequirePackage{babel}
\RequirePackage{shorttoc}
\RequirePackage{arsar}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display string (can be translated)
%
\newcommand{\summaryname}{Summary}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Texte d'affichage (traduction française)
%
\addto\captionsfrench{
  \renewcommand{\summaryname}{Sommaire}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New command for render
%
\newcommand{\summary}[1][1]{\shorttableofcontents{\summaryname}{#1}}


